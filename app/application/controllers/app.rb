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

      # GET /result
      router.on 'result' do
        router.is do
          router.post do
            query_form = Forms::Query.new.call(router.params)
            skill_analysis = Service::AnalyzeSkills.new.call(query_form)

            if skill_analysis.failure?
              flash[:error] = skill_analysis.failure
              router.redirect '/'
            end

            jobskill = skill_analysis.value!
            skillset = Views::SkillJob.new(
              jobskill[:query], jobskill[:jobs], jobskill[:skills], jobskill[:salary_dist]
            )

            flash[:notice] = "Your last query is '#{skillset.query}'"
            view 'result', locals: { skillset: skillset }
          end
        end
      end
    end
  end
end
