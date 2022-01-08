# frozen_string_literal: true

require_relative 'skill'
require_relative 'job'

module  Views
  # A view object that holds all data about Skillset
  class Filter
    def initialize(locations)
      @locations = locations
    end

    attr_reader :locations
  end
end
