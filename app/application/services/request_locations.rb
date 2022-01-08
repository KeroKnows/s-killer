# frozen_string_literal: true

require 'dry/transaction'

module Skiller
  module Service
    # Get job details with the given job id
    class RequestLocations
      include Dry::Transaction

      step :retrieve_locations
      step :reify_result

      # Request available location list from Skiller::API
      def retrieve_locations
        result = Gateway::Api.new(App.config).request_location_list
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        Failure("Fail to retrieve location list: #{e}")
      end

      # Transform result back to a representer
      def reify_result(result_json)
        Representer::Locations.new(OpenStruct.new).from_json(result_json)
                              .then { |result| Success(result) }
      rescue StandardError => e
        Failure("Fail to reify location list: #{e}")
      end
    end
  end
end
