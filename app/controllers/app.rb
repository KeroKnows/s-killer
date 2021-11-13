# frozen_string_literal: true

require 'roda'
require 'slim'

module Skiller
  # Web Application for S-killer
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :halt

    route do |router|
      # GET /
      router.root do
        query = router.params['query']

        view 'index', locals: { query: query }
      end

      # GET /index
      router.on 'index' do
        router.is do
          router.redirect('/')
        end
      end

      router.on 'details' do
        router.is do
          # GET /details?query=[query]
          router.get do
            router.halt 400 unless router.params.include? 'query'

            query = router.params['query']

            jobs = JobCollector.new(App.config).jobs(query)

            view 'details', locals: { query: query, jobs: jobs }
          end
        end
      end
    end

    # request jobs using API if the query has not saved to database
    class JobCollector
      def initialize(config)
        @partial_job_mapper = Skiller::Reed::PartialJobMapper.new(config)
        @job_mapper = Skiller::Reed::JobMapper.new(config)
      end

      def jobs(query)
        if Repository::QueriesJobs.query_exist?(query)
          Repository::QueriesJobs.find_jobs_by_query(query)
        else
          request_jobs_and_update_database(query)
        end
      end

      def request_jobs_and_update_database(query)
        partial_jobs = @partial_job_mapper.job_list(query)
        jobs = partial_jobs[0...10].map { |pj| Repository::Jobs.create(@job_mapper.job(pj.job_id)) }
        jobs = jobs.map { |job| Repository::Jobs.create(job) }
        Repository::QueriesJobs.create(query, jobs.map(&:db_id))
        jobs
      end
    end
    # puts config.DB_FILENAME
  end
end
