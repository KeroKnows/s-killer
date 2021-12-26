# frozen_string_literal: true

module Views
  # A view object that holds all data about job
  class AnalyzeProcess
    def initialize(config, query, response)
      @config = config
      @query = query
      @response = response
    end

    attr_reader :query

    def in_progress?
      @response.processing?
    end

    def channel_id
      @response.message['request_id'] if in_progress?
    end

    def javascript_url
      @config.API_HOST + '/faye/faye.js' if in_progress?
    end

    def server_route
      @config.API_HOST + '/faye/faye' if in_progress?
    end
  end
end
