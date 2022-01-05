# frozen_string_literal: true

require 'dry-validation'
require 'dry-monads'

module Skiller
  module Forms
    # Form object to check query exists
    class SkillQuery
      include Dry::Monads[:result]

      # Contract to validate form contents
      class Contract < Dry::Validation::Contract
        params do
          required(:skills).filled(:string)
        end

        rule(:skills) do
          key.failure('should not be empty') if value.strip.empty?
        end
      end

      def call(input)
        contract = Contract.new.call(input)
        return Failure(contract.errors.to_h) if contract.failure?

        skill_list = contract[:skills].split(/[,\n\s]+/)
        query = query_to_s(skill_list)
        Success(query: query)
      end

      private

      def query_to_s(skills)
        skills = skills.map { |skill| "name[]=#{skill}" }
        skills.join('&')
      end
    end
  end
end
