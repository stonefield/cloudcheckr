require_relative "./api/controller"
require_relative "./api/controllers"
require_relative "./api/client"
require_relative "./api/response_error"

module CloudCheckr
  module API
    CONTROLLERS ||= CloudCheckr::API::Controllers.build_controller_classes!

    @@access_key           = ENV['CLOUDCHECKR_ACCESS_KEY']
    @@use_account          = ENV['CLOUDCHECKR_USE_ACCOUNT']
    @@connection_builder   = nil
    @@snake_case_json_keys = true

    def self.access_key(new_access_key = nil)
      unless new_access_key.nil?
        @@access_key = new_access_key
      end

      @@access_key
    end

    def self.use_account(new_use_account = nil)
      unless new_use_account.nil?
        @@use_account = new_use_account
      end

      @@use_account
    end

    def self.connection_builder(&builder)
      if block_given?
        @@connection_builder = builder
      end

      @@connection_builder
    end

    def self.snake_case_json_keys(enable = nil)
      unless enable.nil?
        @@snake_case_json_keys = enable
      end

      @@snake_case_json_keys
    end
  end
end

# Dynamically create methods on the Client class for each controller

CloudCheckr::API::CONTROLLERS.each do |controller_name, controller_class|
  CloudCheckr::API::Client.send(:define_method, controller_name) do
    instance_variable_get(:"@#{controller_name}") || instance_variable_set(:"@#{controller_name}", controller_class.new(self))
  end
end

# Dynamically expose list of controllers available

controller_names = CloudCheckr::API::CONTROLLERS.keys
CloudCheckr::API::Client.send(:define_method, :controller_names){ controller_names }
