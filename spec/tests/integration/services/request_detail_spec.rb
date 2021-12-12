# frozen_string_literal: true

require_relative '../../../helpers/vcr_helper'
require_relative '../../../spec_helper'

describe 'Integration Test for RequestDetail Service' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_api
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  it 'HAPPY: should search detail with job_id' do
    # GIVEN: a healthy job_id
    job_detail = Skiller::Service::RequestDetail.new.call(TEST_JOB_ID)

    # THEN: service should succeed
    _(job_detail.success?).must_equal true
    job_detail = job_detail.value!

    # ...with job detail returned
    _(job_detail).must_respond_to :title
    _(job_detail).must_respond_to :description
    _(job_detail).must_respond_to :location
    _(job_detail).must_respond_to :salary
    _(job_detail).must_respond_to :url
  end
end
