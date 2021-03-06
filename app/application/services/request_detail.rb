# frozen_string_literal: true

require 'dry/transaction'

module Skiller
  module Service
    # Get job details with the given job id
    class RequestDetail
      include Dry::Transaction

      step :retrieve_detail
      step :reify_result

      # Request job detail from Skiller::API
      def retrieve_detail(job_id)
        result = Gateway::Api.new(App.config).request_detail(job_id)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        Failure("Fail to retrieve job detail: #{e}")
      end

      # Transform result back to a representer
      def reify_result(result_json)
        Representer::Detail.new(OpenStruct.new).from_json(result_json)
                           .then { |result| Success(result) }
      rescue StandardError => e
        Failure("Fail to reify job detail: #{e}")
      end
    end
  end
end
