# frozen_string_literal: true

require_relative '../spec_helper'

module Skiller
  # provide spec utility functions of VCR
  # :reek:TooManyStatements for serial configuration
  module VcrHelper
    CASSETTES_FOLDER = 'spec/fixtures/cassettes'
    SKILLER_API_CASSETTE = 'skiller'

    def self.setup_vcr
      VCR.configure do |config|
        config.cassette_library_dir = CASSETTES_FOLDER
        config.hook_into :webmock
      end
    end

    def self.configure_api
      VCR.insert_cassette SKILLER_API_CASSETTE,
                          record: :new_episodes,
                          match_requests_on: %i[method uri headers]
    end

    def self.eject_vcr
      VCR.eject_cassette
    end
  end
end
