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

  it 'BAD: should fail empty request' do
    # GIVEN: an empty query
    params = {}

    # WHEN: the service is called
    search_result = Skiller::Service::FilterSearch.new.call(params)

    # THEN: the service should fail
    _(search_result.failure?).must_equal true
    _(search_result.failure.downcase).must_include 'should be given'
  end

  it 'HAPPY: should search healthy query and get result' do
    # GIVEN: a valid, existing query
    params = TEST_SKILLSET

    # WHEN: the service is called
    search_result = Skiller::Service::FilterSearch.new.call(params)

    # THEN: the service should succeed...
    _(search_result.success?).must_equal true

    # ... and get correct data
    result = search_result.value![:result]
    _(result).must_respond_to :query
    _(result).must_respond_to :jobs
    _(result).must_respond_to :skills
    _(result).must_respond_to :salary_dist
  end
end
