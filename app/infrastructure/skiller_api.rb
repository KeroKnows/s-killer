# frozen_string_literal: true

require 'http'

module Skiller
  module Gateway
    # Infrastructure to call Skiller API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      # Ensure our API is alive
      def alive?
        @request.get_root.success?
      end

      # GET result from given query
      def result(query)
        @request.get_result(query)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{@api_host}/api/v1"
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def get_result(query)
          url = get_route(['jobs'], 'query' => query)
          call_api('get', url)
        end

        private

        def get_route(resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          params_str = Parameters.new(params).to_s
          [api_path, resources].flatten.join('/') + params_str
        end

        # Send request to our api
        def call_api(method, url = nil)
          url ||= @api_host
          HTTP.headers('Accept' => 'application/json').send(method, url)
              .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Utitity class for handling HTTP parameters
      class Parameters
        def initialize(params)
          @params = params
        end

        # transform parameter lists into a string
        def to_s
          @params.map { |key, value| "#{key}=#{value}" }.join('&')
                 .then { |str| str.empty? ? '' : "?#{str}" }
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        # Error for request failure
        NotFound = Class.new(StandardError)

        SUCCESS = (200..299)

        def success?
          code.between?(SUCCESS.first, SUCCESS.last)
        end

        def message
          response = JSON.parse payload
          response['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
