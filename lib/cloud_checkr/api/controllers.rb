require 'yaml'

module CloudCheckr
  module API
    module Controllers

      # Returns a [Hash] with controller name and class
      def self.build_controller_classes!
        endpoints_path    = File.join(File.dirname(__FILE__), 'endpoints.yml')
        endpoints_schemas = YAML.load_file(endpoints_path)
        controllers       = {}

        # Define a controller class for each controller name
        endpoints_schemas.each do |schema|
          controller_name       = schema['controller_name'].to_sym
          controller_class_name = schema['controller_name'].split('_').collect(&:capitalize).join + 'Controller'

          controller_class = Class.new(::CloudCheckr::API::Controller) do
            method_names = []

            # Define a method for each API call
            schema['api_calls'].each do |api_call|
              method_name     = api_call['method_name'].to_sym
              required_params = api_call['param_names'].lazy.select{|name| name.include?('(required)')}.map{|name| name.gsub(/\([^\)]+\)/, '').to_sym}.to_a

              if api_call['method_name'].start_with?('get_')
                define_method(method_name) do |params = {}, headers = nil, &request_builder|
                  @client.get(controller_name, method_name, params, headers, &request_builder)
                end
              else
                define_method(method_name) do |params = {}, headers = nil, &request_builder|
                  @client.post(controller_name, method_name, params, headers, &request_builder)
                end
              end

              method_names << method_name
            end

            define_method(:api_calls){ method_names }
          end

          # Register the class within the Controllers module
          self.const_set(controller_class_name, controller_class)

          controllers[controller_name] = controller_class
        end

        controllers
      end

    end
  end
end