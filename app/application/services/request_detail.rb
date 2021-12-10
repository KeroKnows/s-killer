# frozen_string_literal: true

require 'dry/monads'

module Skiller
  module Service
    # Get job details with the given job id
    class RequestDetail
      include Dry::Monads::Result::Mixin

      # :reek:UncommunicativeVariableName for rescued error
      def call(job_id)
        job = Repository::For.klass(Entity::Job).find_db_id(job_id)

        if job
          job.is_full ? Success(job) : Failure('Lack of full information')
        else
          Failure("Job##{job_id} not found. Please request it in advance")
        end
      rescue StandardError => e
        Failure("Fail to get job info from database: #{e}")
      end
    end
  end
end
