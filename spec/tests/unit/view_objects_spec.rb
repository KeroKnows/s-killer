# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'Test View Objects' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_currency
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Test Job Object' do
    before do
      salary = Skiller::Value::Salary.new(year_min: 1.0, year_max: 100.0, currency: 'TWD')
      @job = Skiller::Entity::Job.new(db_id: 1,
                                      job_id: 1,
                                      title: 'JOB TITLE',
                                      description: '<h1>JOB TITLE</h1><p>description</p>',
                                      location: 'LOCATION',
                                      salary: salary,
                                      url: 'URL',
                                      is_full: true)
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
      skill = Skiller::Entity::Skill.new(id: nil,
                                         job_db_id: nil,
                                         name: 'Python',
                                         salary: nil)
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
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'AWS', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary)
      ]
      skilljob = Views::SkillJob.new(nil, nil, skills, nil)
      skilljob.skills.each do |skill|
        _(skill).must_be_instance_of Views::Skill
      end
    end

    it 'HAPPY: should sort the skillset by count' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'AWS', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'AWS', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'JavaScript', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'JavaScript', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'JavaScript', salary: salary)
      ]
      skilljob = Views::SkillJob.new(nil, nil, skills, nil)
      count = skilljob.skills.map(&:count)
      _(count).must_equal count.sort.reverse!
    end

    it 'HAPPY: should return the job object' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      jobs = [Skiller::Entity::Job.new(db_id: nil,
                                       job_id: 0,
                                       title: 'JOB1 TITLE',
                                       description: '<h1>JOB1 TITLE</h1><p>description</p>',
                                       location: 'LOCATION',
                                       salary: salary,
                                       url: 'URL',
                                       is_full: true),
              Skiller::Entity::Job.new(db_id: nil,
                                       job_id: 1,
                                       title: 'JOB2 TITLE',
                                       description: '<h1>JOB2 TITLE</h1><p>description</p>',
                                       location: 'LOCATION',
                                       salary: salary,
                                       url: 'URL',
                                       is_full: true)]

      skilljob = Views::SkillJob.new(nil, jobs, nil, nil)
      skilljob.jobs.each do |job|
        _(job).must_be_instance_of Views::Job
      end
    end

    it 'HAPPY: should correctly calculate the max/min salary' do
      max_salary = Skiller::Value::Salary.new(year_min: 10.0, year_max: 1000.0, currency: 'USD')
      min_salary = Skiller::Value::Salary.new(year_min: 1.0, year_max: 100.0, currency: 'USD')
      nil_salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      salaries = [max_salary, min_salary, nil_salary]
      salary_distribution = Skiller::Entity::SalaryDistribution.new(salaries, 'TWD')
      skilljob = Views::SkillJob.new(nil, nil, nil, salary_distribution)
      _(skilljob.max_salary).must_equal "TWD$ #{max_salary.exchange_currency('TWD').year_max.to_i}"
      _(skilljob.min_salary).must_equal "TWD$ #{min_salary.exchange_currency('TWD').year_min.to_i}"
    end
  end
end
