# frozen_string_literal: true

require 'nokogiri'

module Views
  # A view object that holds all data about job
  class Job
    def initialize(job)
      @job = job
      @salary = job.salary
      @description = nil
    end

    def id
      @job.db_id
    end

    def title
      @job.title
    end

    def location
      @job.location
    end

    def brief
      "#{description[0, 300]}..."
    end

    def description
      parse_description
      @description
    end

    def url
      @job.url
    end

    def level
      @job.job_level
    end

    def max_salary
      "#{@salary.currency}$ #{@salary.year_max}"
    end

    def min_salary
      "#{@salary.currency}$ #{@salary.year_min}"
    end

    # UTILITIES

    def parse_description
      return if @description

      # [ TODO ] extract text with line break
      doc = Nokogiri::HTML(@job.description)
      @description = doc.xpath('//text()').to_a.join(' ')
    end
  end
end
