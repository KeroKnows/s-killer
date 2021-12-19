# frozen_string_literal: true

require_relative '../../helpers/acceptance_helper'
require_relative '../../helpers/vcr_helper'
require_relative 'pages/index_page'
require_relative 'pages/detail_page'

describe 'Detail Page Acceptance Tests' do
  include PageObject::PageFactory
  Skiller::VcrHelper.setup_vcr

  before do
    Skiller::VcrHelper.configure_api
    @browser ||= Watir::Browser.new :chrome, headless: true
  end

  after do
    @browser.close
    Skiller::VcrHelper.eject_vcr
  end

  it '(HAPPY) should see job details' do
    # GIVEN: the job has been properly extracted
    visit(IndexPage) do |page|
      page.query_job(TEST_KEYWORD)
    end

    # WHEN: user goes to the detail page
    #   Sorry for the shitty testing logic here.
    #   It may break but most of the time it works fine.
    job_id = TEST_JOB_ID
    visit(DetailPage, using_params: { job_id: job_id }) do |page|
      # THEN: details should show correctly
      _(page.title_element.present?).must_equal true
      _(page.meta_box_element.present?).must_equal true
      _(page.info_box_element.present?).must_equal true
    end
  end

  it '(BAD) should not be able to request an invalid job id' do
    # GIVEN: a pretty large job id that should not be available in database (hopefully)
    job_id = INVALID_JOB_ID

    # WHEN: user visits the page
    visit(DetailPage, using_params: { job_id: job_id })

    # THEN: they should be sent back to home page with a error message
    on_page IndexPage do |page|
      _(page.warning_message_element.text.downcase).must_include 'not found'
    end
  end
end
