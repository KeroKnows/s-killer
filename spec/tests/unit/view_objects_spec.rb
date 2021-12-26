# frozen_string_literal: true

require_relative '../../helpers/vcr_helper'
require_relative '../../spec_helper'

# Fake process message
ProcessMessage = Struct.new(:task_count, :request_id)
# Fake Job entity
Job = Struct.new(:title, :description, :location, :salary, :db_id)
# Fake Skill entity
Skill = Struct.new(:name, :salary)
# Fake Salary entity
Salary = Struct.new(:year_min, :year_max, :currency)
# Fake SalaryDistribution entity
SalaryDistribution = Struct.new(:maximum, :minimum, :currency)

describe 'Test View Objects' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_api
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Test Job Object' do
    before do
      salary = Salary.new(10.0, 1000.0, 'TWD')
      @job = Job.new('JOB TITLE', '<h1>JOB TITLE</h1><p>description</p>', 'LOCATION', salary, 1)
      @job_object = Views::Job.new(@job)
    end

    it 'HAPPY: should extract properties properly' do
      _(@job_object.id).must_equal @job.db_id
      _(@job_object.title).must_equal @job.title
      _(@job_object.location).must_equal @job.location
      _(@job_object.max_salary).must_equal "#{@job.salary.currency}$ #{@job.salary.year_max}"
      _(@job_object.min_salary).must_equal "#{@job.salary.currency}$ #{@job.salary.year_min}"
    end

    it 'HAPPY: should parse description to pure text' do
      _(@job_object.description).wont_match %r{</?\w+>}
    end

    it 'HAPPY: should be able to provide the brief description' do
      _(@job_object.brief.length).must_be :<, 305
    end
  end

  describe 'Test Skill Object' do
    it 'HAPPY: should extract properties properly' do
      skill = Skill.new('Python')
      count = 10
      skill_object = Views::Skill.new(skill, count)
      _(skill_object.name).must_equal skill.name
      _(skill_object.count).must_equal count
    end

    it 'HAPPY: should return related jobs' do
      skip 'NOT IMPLEMENTED'
    end
  end

  describe 'Test SkillJob Object' do
    it 'HAPPY: should extract the skillset as skill object' do
      skills = [Skill.new('AWS'), Skill.new('Python')]
      skilljob = Views::SkillJob.new(nil, nil, skills, nil)
      skilljob.skills.each do |skill|
        _(skill).must_be_instance_of Views::Skill
      end
    end

    it 'HAPPY: should sort the skillset by count' do
      skill_names = %w[AWS Python AWS Python JavaScript Python JavaScript JavaScript]
      skills = skill_names.map { |name| Skill.new(name) }
      skilljob = Views::SkillJob.new(nil, nil, skills, nil)
      count = skilljob.skills.map(&:count)
      _(count).must_equal count.sort.reverse!
    end

    it 'HAPPY: should return the job object' do
      jobs = [
        Job.new('JOB1', '<h1>JOB1 TITLE</h1><p>description</p>', 'LOCATION'),
        Job.new('JOB2', '<h1>JOB2 TITLE</h1><p>description</p>', 'LOCATION')
      ]
      skilljob = Views::SkillJob.new(nil, jobs, nil, nil)
      skilljob.jobs.each do |job|
        _(job).must_be_instance_of Views::Job
      end
    end

    it 'HAPPY: should correctly calculate the max/min salary' do
      max_salary = 10_000
      min_salary = 10
      salary_distribution = SalaryDistribution.new(max_salary, min_salary, 'TWD')

      skilljob = Views::SkillJob.new(nil, nil, nil, salary_distribution)
      _(skilljob.max_salary).must_equal "TWD$ #{max_salary}"
      _(skilljob.min_salary).must_equal "TWD$ #{min_salary}"
    end
  end

  describe 'Test AnalyzeProcess Object' do
    it 'HAPPY: should correctly decide if the result is still under processing' do
      # Fake API response
      class Response
        def processing?; true; end
        def message; ProcessMessage.new(10, 10); end
      end
      process = Views::AnalyzeProcess.new(Skiller::App.config, nil, Response.new)
      _(process.in_progress?).must_equal true

      # Fake API response
      class Response
        def processing?; false; end
        def message; ProcessMessage.new(10, 10); end
      end
      process = Views::AnalyzeProcess.new(Skiller::App.config, nil, Response.new)
      _(process.in_progress?).must_equal false
    end

    it 'HAPPY: should return correct info' do
      job_count = 10
      channel_id = 1000
      # Fake API response
      class Response
        def processing?; true; end
        def message; ProcessMessage.new(10, 1000); end # modify this along with previous definition
      end
      process = Views::AnalyzeProcess.new(Skiller::App.config, nil, Response.new)

      _(process.task_count).must_equal job_count
      _(process.channel_id).must_equal channel_id
    end

    it 'HAPPY: should get faye server info' do
      # Fake API response
      class Response
        def processing?; true; end
        def message; ProcessMessage.new(nil, nil); end
      end
      process = Views::AnalyzeProcess.new(Skiller::App.config, nil, Response.new)

      _(process.javascript_url).wont_be_nil
      _(process.server_route).wont_be_nil
    end
  end
end
