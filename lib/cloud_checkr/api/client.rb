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
        super()

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
        {access_key: @access_key}
      end

      def require_params!(required_params, params)
        missing_required_params = required_params.map(&:to_sym) - prepare_params(params).keys.map(&:to_sym)
        
        if missing_required_params.any?
          raise "Missing required parameters: #{missing_required_params.join(', ')}"
        else
          nil
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
        else
          data
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

        faraday.response :xml,     content_type: /\bxml$/
        faraday.response :json,    content_type: /\bjson$/
        faraday.response :mashify, content_type: /\bjson$/
        # faraday.response @format
        # faraday.response :mashify if @format == :json

        # faraday.response :logger, nil, bodies: true
        # faraday.response :detailed_logger

        faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
  end
end
