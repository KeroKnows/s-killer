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
    locations = Skiller::Service::RequestLocations.new.call

    # THEN: service should succeed
    _(locations.success?).must_equal true
    locations = locations.value!

    # ...with job detail returned
    _(locations).must_respond_to :locations
  end
end
