# frozen_string_literal: true

require_relative '../../../helpers/vcr_helper'
require_relative '../../../spec_helper'

describe 'Integration Test for AnalyzeSkills Service' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_api
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  it 'BAD: should fail empty query' do
    # GIVEN: an empty query
    query_form = Skiller::Forms::Query.new.call(query: EMPTY_KEYWORD)

    # WHEN: the service is called
    jobskill = Skiller::Service::AnalyzeSkills.new.call(query_form)

    # THEN: the service should fail
    _(jobskill.failure?).must_equal true
    _(jobskill.failure.downcase).must_include 'invalid'
  end

  it 'HAPPY: should search unseen query and get processing status' do
    # GIVEN: a valid, non-existing query
    query_form = Skiller::Forms::Query.new.call(query: NEW_KEYWORD)

    # WHEN: the service is called
    skill_analysis = Skiller::Service::AnalyzeSkills.new.call(query_form)

    # THEN: the service should succeed...
    _(skill_analysis.success?).must_equal true

    # ... and shoule indicate itself being analyzed
    skill_analysis = skill_analysis.value!
    _(skill_analysis[:response].processing?).must_equal true
  end

  it 'HAPPY: should search healthy query and get result' do
    # GIVEN: a valid, existing query
    query_form = Skiller::Forms::Query.new.call(query: TEST_KEYWORD)

    # WHEN: the service is called
    skill_analysis = Skiller::Service::AnalyzeSkills.new.call(query_form)

    # THEN: the service should succeed...
    _(skill_analysis.success?).must_equal true

    # ... and get correct data
    jobskill = skill_analysis.value![:result]
    _(jobskill).must_respond_to :query
    _(jobskill).must_respond_to :jobs
    _(jobskill).must_respond_to :skills
    _(jobskill).must_respond_to :salary_dist
  end
end
