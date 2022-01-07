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

      # GET /search
      router.on 'search' do
        view 'search'
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

      router.on 'results' do
        router.on 'skills' do
          # POST /results/skills
          router.post do
            query_form = Forms::JobQuery.new.call(router.params)

            if query_form.failure?
              error_msg = query_form.errors.to_h.map { |key, val| "#{key} #{val.first}" }.join(', ')
              flash[:error] = "invalid query: #{error_msg}"
              router.redirect '/'
            end

            router.redirect "/results/skills?query=#{query_form[:query]}"
          end

          # GET /results/skills?query=<QUERY>
          router.get do
            query_form = Forms::JobQuery.new.call(router.params)
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
            end

            process_info = Views::AnalyzeProcess.new(App.config, skill_analysis[:query], response)

            view 'result_skill', locals: { skillset: skillset,
                                           process: process_info }
          end
        end

        router.on 'jobs' do
          # POST /results
          router.post do
            search_form = Forms::SkillQuery.new.call(router.params)

            if search_form.failure?
              error_msg = search_form.failure.map { |key, val| "#{key} #{val.first}" }.join(', ')
              flash[:error] = "invalid skillset: #{error_msg}"
              router.redirect '/search'
            end

            search_form = search_form.value!
            router.redirect "/results/jobs?#{search_form[:query]}"
          end

          # GET /results/jobs?name[]=<SKILL>
          router.get do
            filter_search = Service::FilterSearch.new.call(router.params)

            if filter_search.failure?
              flash[:error] = filter_search.failure
              router.redirect '/search'
            end

            filter_search = filter_search.value!
            jobskill = filter_search[:result]
            skillset = Views::SkillJob.new(
              jobskill[:query], jobskill[:jobs], jobskill[:skills], jobskill[:salary_dist]
            )

            view 'result_job', locals: { skillset: skillset }
          end
        end
      end
    end
  end
end
