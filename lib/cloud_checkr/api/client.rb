require 'logger'
require 'ostruct'
require 'faraday'
require 'faraday_middleware'
# require 'faraday/detailed_logger'

module CloudCheckr
  module API
    class Client
      DEFAULT_URL    = "https://api2.cloudcheckr.com".freeze
      DEFAULT_FORMAT = :json

      attr_reader :access_key, :url, :format

      def initialize(options = {}, &connection_builder)
        @access_key         = options.fetch(:access_key,  API.access_key)
        @use_account        = options.fetch(:use_account, API.use_account)
        @url                = options.fetch(:url,         DEFAULT_URL)
        @format             = options.fetch(:format,      :json)
        @connection_builder = connection_builder
      end

      # API

      def get(controller_name, api_call, params = nil, headers = nil, &request_builder)
        handle_response api.get(prepare_path(controller_name, api_call), prepare_params(params), headers, &request_builder)
      end

      def post(controller_name, api_call, params = nil, headers = nil, &request_builder)
        handle_response api.post(prepare_path(controller_name, api_call), prepare_params(params), headers, &request_builder)
      end

      def api
        @api ||= build_connection
      end

      def default_params
        {}.tap do |params|
          params[:access_key]  = @access_key  unless @access_key.nil?
          params[:use_account] = @use_account unless @use_account.nil?
        end
      end

      protected

      def prepare_path(controller_name, api_call)
        "/api/#{controller_name}.#{@format}/#{api_call}"
      end

      def prepare_params(params)
        if params.nil?
          default_params
        else
          default_params.merge(params)
        end
      end

      def handle_response(response)
        data = response.body

        if response.status != 200
          # TODO: Currently assumes JSON response
          raise ::CloudCheckr::API::ResponseError.new(data)
        elsif @format == :json && ::CloudCheckr::API.snake_case_json_keys
          convert_keys_to_snake_case(data)
        else
          data
        end
      end

      def convert_keys_to_snake_case(hash)
        hash_class = hash.class

        if hash.is_a?(Hash)
          hash_class.new.tap do |new_hash|
            hash.map do |k, v|
              new_hash[k.gsub(/(.)([A-Z])/,'\1_\2').downcase] = convert_keys_to_snake_case(v)
            end
          end
        elsif hash.is_a?(Array)
          hash.map{|item| convert_keys_to_snake_case(item)}
        else
          hash
        end
      end

      def build_connection
        Faraday.new(url: @url) do |faraday|
          apply_connection_settings(faraday)

          # Apply global settings, then instance settings
          [::CloudCheckr::API.connection_builder, @connection_builder].each do |builder|
            builder.call(faraday) if builder
          end
        end
      end

      def apply_connection_settings(faraday)
        faraday.request @format
        # form-encode POST params
        faraday.request :url_encoded

        faraday.response :mashify
        faraday.response :xml,  content_type: /\bxml$/
        faraday.response :json, content_type: /\bjson$/

        # faraday.response :logger, nil, bodies: true
        # require 'faraday/detailed_logger'
        # faraday.response :detailed_logger

        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
  end
end
