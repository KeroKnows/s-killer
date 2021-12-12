# frozen_string_literal: true

require 'dry-validation'

module Skiller
  module Forms
    # Form object to check query exists
    class Query < Dry::Validation::Contract
      params do
        required(:query).filled(:string)
      end

      rule(:query) do
        key.failure('is an empty request') if value.strip.empty?
      end
    end
  end
end
