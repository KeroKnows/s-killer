# frozen_string_literal: true

require 'http'

require_relative '../../helpers/vcr_helper'
require_relative '../../spec_helper'

# Fake HTTP::Response object
HTTPResponse = Struct.new(:code, :status, :body)

describe 'Test Skiller Gateway' do
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_api
  end

  after do
    Skiller::VcrHelper.eject_vcr
  end

  describe 'Test Parameter Library' do
    it 'HAPPY: should retuen empty string if parameter is empty' do
      param = {}
      _(Skiller::Gateway::Api::Parameters.new(param).to_s).must_be_empty
    end

    it 'HAPPY: should be able to combine single parameter' do
      param = { key: 'value' }
      _(Skiller::Gateway::Api::Parameters.new(param).to_s).must_equal '?key=value'
    end

    it 'HAPPY: should be able to combine multiple parameters' do
      # multiple keys
      params = { key1: 'value1', key2: 'value2' }
      _(Skiller::Gateway::Api::Parameters.new(params).to_s).must_equal '?key1=value1&key2=value2'
    end
  end

  describe 'TEST Response Library' do
    it 'HAPPY: should be able to confirm success' do
      http_response = HTTPResponse.new(200,
                                       HTTP::Response::Status.new(200),
                                       HTTP::Response::Body.new('success'))
      response = Skiller::Gateway::Api::Response.new(http_response)
      _(response.success?).must_equal true
    end
  end

  describe 'Test Basic Utilities' do
    it 'HAPPY: should be able to check API status' do
      api = Skiller::Gateway::Api.new(CONFIG)
      _(api.alive?).wont_be_nil
    end

    it 'HAPPY: should be able to request the result' do
      api = Skiller::Gateway::Api.new(CONFIG)
      result = api.request_skillset(TEST_KEYWORD)

      _(result).must_be_instance_of Skiller::Gateway::Api::Response
      _(result).must_respond_to :payload
      _(result).must_respond_to :message
      # Not testing result content here, since gateway should be innocent of contents
    end
  end
end
