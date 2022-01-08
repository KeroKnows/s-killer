# frozen_string_literal: true

require 'dry/transaction'

module Skiller
  module Service
    # Get job details with the given job id
    class FilterSearch
      include Dry::Transaction

      step :validate_request
      step :request_api
      step :reify_result

      # Validate user input
      def validate_request(params)
        return Failure('At least on param should be given') if params.empty?

        skills = params['name']
        Success(name: skills)
      rescue StandardError => e
        Failure("Fail to validate the request: #{e}")
      end

      # Search the jobs with filter from Skiller::API
      def request_api(input)
        response = Gateway::Api.new(App.config).request_searching(input)
        return Failure(response.message) unless response.success?

        input[:response] = response
        Success(input)
      rescue StandardError => e
        Failure("Fail to request API: #{e}")
      end

      # Transform result back to a representer
      def reify_result(input)
        response = input[:response]
        if response.ok?
          input[:result] = Representer::Result.new(OpenStruct.new)
                                              .from_json(response.payload)
        end
        Success(input)
      rescue StandardError => e
        Failure("Fail to reify query result: #{e}")
      end
    end
  end
end
