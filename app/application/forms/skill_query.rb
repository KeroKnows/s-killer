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
          required(:job_level).filled(:string)
          required(:location).filled(:string)
        end

        rule(:skills) do
          key.failure('should not be empty') if value.strip.empty?
        end
      end

      def call(input)
        contract = Contract.new.call(input)
        return Failure(contract.errors.to_h) if contract.failure?

        params = process_form(contract)
        query = params_to_s(params).join('&')
        Success(query: query)
      end

      private

      def process_form(contract)
        params = {}
        params[:name] = contract[:skills].split(/[,\n\s]+/)
        params = process_level(contract[:job_level], params)
        process_location(contract[:location], params)
      end

      def params_to_s(params)
        params.map do |key, values|
          expand_query(key, values)
        end
      end

      def expand_query(key, value)
        value.map { |val| "#{key}[]=#{val}" }.join('&')
      rescue NoMethodError
        "#{key}=#{value}"
      end

      def process_level(level, params)
        params[:job_level] = level unless level.match? 'all'
        params
      end

      def process_location(location, params)
        params[:location] = location unless location.match? 'all'
        params
      end
    end
  end
end
