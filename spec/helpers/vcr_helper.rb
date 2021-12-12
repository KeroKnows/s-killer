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
        # ignore driver communicution during the acceptance test
        config.ignore_request { |request| filter_request(request) }
        config.cassette_library_dir = CASSETTES_FOLDER
        config.hook_into :webmock
      end
    end

    def self.filter_request(request)
      uri = URI(request.uri)
      should_fail = (uri.host.include? '127.0.0.1')\
                    && (uri.path.match? 'session')\
                    && (request.headers['User-Agent'].any? { |ua| ua.include? 'watir' })
      return true if should_fail

      should_fail = (uri.host.include? '127.0.0.1')\
                    && (uri.path.match? 'shutdown$')
      should_fail
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
