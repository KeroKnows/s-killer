# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'Test Application Form' do
  describe 'Test SkillQuery Form' do
    it 'BAD: should fail empty query' do
      empty_query = {}
      query_form = Skiller::Forms::SkillQuery.new.call(empty_query)

      _(query_form.failure?).must_equal true
    end

    it 'BAD: should fail empty skill string' do
      empty_skill_query = { skills: '   ', location: 'LOCATION', job_level: 'LEVEL' }
      query_form = Skiller::Forms::SkillQuery.new.call(empty_skill_query)

      _(query_form.failure?).must_equal true
    end

    it 'HAPPY: should transform form data into query' do
      skills = %w[Ruby JavaScript Python]
      skill_query = { skills: skills.join(','), location: 'LOCATION', job_level: 'LEVEL' }

      query_form = Skiller::Forms::SkillQuery.new.call(skill_query)
      _(query_form.success?).must_equal true

      query_value = query_form.value!
      _(query_value[:query]).must_match 'name[]=Ruby&name[]=JavaScript&name[]=Python'
    end

    it 'HAPPY: should be able to deal with different seperator' do
      skills = %w[Ruby JavaScript Python]
      seperators = [',', "\n", ' ', " \n,", " \n ,", ", \n", ",\n ", "\n\n", "  \n"]
      seperators.each do |sep|
        skill_query = { skills: skills.join(sep), location: 'LOCATION', job_level: 'LEVEL' }

        query_form = Skiller::Forms::SkillQuery.new.call(skill_query)
        _(query_form.success?).must_equal true

        query_value = query_form.value!
        _(query_value[:query]).must_match 'name[]=Ruby&name[]=JavaScript&name[]=Python'
      end
    end

    it 'HAPPY: should omit the location and job_level if it indicates all' do
      skills = %w[Ruby JavaScript Python]
      skill_query = { skills: skills.join(','), location: 'all', job_level: 'all' }

      query_form = Skiller::Forms::SkillQuery.new.call(skill_query)
      _(query_form.success?).must_equal true

      query_value = query_form.value!
      _(query_value[:query]).must_match 'name[]=Ruby&name[]=JavaScript&name[]=Python'
    end
  end
end
