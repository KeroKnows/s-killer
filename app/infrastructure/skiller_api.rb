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
      def request_skillset(query)
        @request.get_skillsets(query)
      end

      # GET detail from given job id
      def request_detail(job_id)
        @request.get_job_detail(job_id)
      end

      # GET skills from given params
      def request_searching(params)
        @request.get_skills(params)
      end

      # GET location list
      def request_location_list
        @request.get_location_list
      end

      # HTTP request transmitter
      # rubocop:disable Naming/AccessorMethodName for GET method
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{@api_host}/api/v1"
        end

        def get_root
          call_api('get')
        end

        def get_skillsets(query)
          url = get_route(['jobs'], 'query' => query)
          call_api('get', url)
        end

        def get_job_detail(job_id)
          url = get_route(['details', job_id.to_s])
          call_api('get', url)
        end

        def get_skills(params)
          url = get_route(['skills'], params)
          call_api('get', url)
        end

        def get_location_list
          url = get_route(['locations'])
          call_api('get', url)
        end

        private

        def get_route(resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          params_str = Parameters.new(params).to_s
          url = [api_path, resources].flatten.join('/') + params_str
          URI.parse(url).to_s
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
      # rubocop:enable Naming/AccessorMethodName

      # Utitity class for handling HTTP parameters
      class Parameters
        def initialize(params)
          @params = params
          @queries = query_to_list
        end

        def query_to_list
          @params.map do |key, value|
            Parameters.expand_query(key, value).join('&')
          rescue NoMethodError
            "#{key}=#{value}"
          end
        end

        # transform parameter lists into a string
        def to_s
          @queries.join('&')
                  .then { |str| str.empty? ? '' : "?#{str}" }
        end

        # expand value list into a list of key-value string
        def self.expand_query(key, value)
          value.map { |val| "#{key}=#{val}" }
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

        def ok?
          code == 200
        end

        def processing?
          code == 202
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
