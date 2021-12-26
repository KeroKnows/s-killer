# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module Skiller
  # Web Application for S-killer
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :halt
    plugin :flash

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

      # GET /detail/{JOB_ID}
      router.on 'detail' do
        router.on Integer do |job_id|
          job_info = Service::RequestDetail.new.call(job_id)

          if job_info.failure?
            flash[:error] = job_info.failure
            router.redirect '/'
          end

          job_info = job_info.value!
          job = Views::Job.new(job_info)

          view 'detail', locals: { job: job }
        end
      end

      router.on 'result' do
        router.is do
          # POST /result
          router.post do
            query_form = Forms::Query.new.call(router.params)
            skill_analysis = Service::AnalyzeSkills.new.call(query_form)

            if skill_analysis.failure?
              flash[:error] = skill_analysis.failure
              router.redirect '/'
            end

            skill_analysis = skill_analysis.value!
            response = skill_analysis[:response]
            if response.processing?
              flash[:notice] = 'Skillset is being analyzed now. Please wait for the job done'
            else
              jobskill = skill_analysis[:result]
              skillset = Views::SkillJob.new(
                jobskill[:query], jobskill[:jobs], jobskill[:skills], jobskill[:salary_dist]
              )
              flash[:notice] = "Your last query is '#{skillset.query}'"
              # response.expires(60, public: true) if App.environment == :production
            end

            process_info = Views::AnalyzeProcess.new(App.config, skill_analysis[:query], response)

            view 'result', locals: { skillset: skillset,
                                     process: process_info }
          end
        end
      end
    end
  end
end
