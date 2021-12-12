# frozen_string_literal: true

require 'dry/transaction'

module Skiller
  module Service
    # Request the jobs related to given query, and analyze the skillset from it
    # :reek:TooManyStatements { max_statements: 7 } for Success/Failure and rescued statements
    class AnalyzeSkills
      include Dry::Transaction

      step :validate_request
      step :retrieve_result
      step :reify_result

      private

      # Check if the previous form validation passes
      def validate_request(input)
        query = input[:query]
        if input.success?
          Success(query)
        else
          Failure("Invalid query: '#{query}'")
        end
      end

      # Request result from Skiller::API
      # :reek:UncommunicativeVariableName for rescued error
      def retrieve_result(query)
        result = Gateway::Api.new(App.config).result(query)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        Failure("Fail to retrieve result: #{e}")
      end

      # Transform result back to a representer
      # :reek:UncommunicativeVariableName for rescued error
      def reify_result(result_json)
        Representer::Result.new(OpenStruct.new).from_json(result_json)
          .then { |result| Success(result) }
      rescue StandardError => e
        Failure("Fail to reify query result: #{e}")
      end
    end
  end
end
