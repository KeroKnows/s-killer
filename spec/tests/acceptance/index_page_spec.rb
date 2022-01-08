# frozen_string_literal: true

require_relative '../../helpers/acceptance_helper'
require_relative '../../helpers/vcr_helper'
require_relative 'pages/index_page'
require_relative 'pages/skill_result_page'

describe 'Indexpage Acceptance Tests' do
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

  index_url = CONFIG.TEST_HOST

  invalid_query_warning = 'invalid'
  empty_result_warning = 'no job found'

  describe 'Visit Index Page' do
    it '(HAPPY) elements should be presented on index page' do
      # Given: index page
      visit IndexPage do |page|
        # When: user wants to send a request
        # User is able to locate where to input and send query
        _(page.query_search_element.present?).must_equal true
        _(page.skill_submit_element.present?).must_equal true
        _(page.skill_search_element.present?).must_equal true
        _(page.job_submit_element.present?).must_equal true
      end
    end

    it '(HAPPY) should be able to request skillset with a query' do
      # Given: on the index page
      visit IndexPage do |page|
        # When: input a valid request
        page.search_skill_with_query(TEST_KEYWORD)

        # Then: jump to the correct result page
        on SkillResultPage do |rpage|
          valid_request_url = TEST_KEYWORD.sub(' ', '+')
          rpage.url.include? valid_request_url
        end
      end
    end

    it '(BAD) should not be able to request an invalid query' do
      # Given: index page
      visit IndexPage do |page|
        # When: user wants to send an invalid request
        # Input an invalid request
        page.search_skill_with_query(INVALID_KEYWORD)

        # Then: user jumps back to index url
        _(@browser.url).must_match index_url

        # Then: user sees flash bar
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message_element.text.downcase).must_include invalid_query_warning
      end
    end

    it '(SAD) should not be able to request blank query' do
      # Given: index page
      visit IndexPage do |page|
        # Input an empty request
        page.search_skill_with_query('')

        # Then: user jumps back to index url
        _(@browser.url).must_match index_url

        # Then: user sees flash bar
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message_element.text.downcase).must_match invalid_query_warning
      end
    end

    it '(SAD) should not be able to request an non-available query' do
      # Given: index page
      visit IndexPage do |page|
        # When: user wants to send an invalid request
        # Input an invalid request
        page.search_skill_with_query(EMPTY_RESULT_KEYWORD)

        # Then: user jumps back to index url
        _(@browser.url).must_match index_url

        # Then: user sees flash bar
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message_element.text.downcase).must_include empty_result_warning
      end
    end

    it '(HAPPY) should be able to request job with skills' do
      # Given: on the index page
      visit IndexPage do |page|
        # When: input a valid request
        page.search_job_with_skill(TEST_SKILLSET_STR)

        # Then: jump to the correct result page
        on SkillResultPage do |rpage|
          valid_request_url = 'name[]=Python&name[]=JavaScript'
          rpage.url.include? valid_request_url
        end
      end
    end

    it '(BAD) should not be able to request job with empty skills' do
      # Given: on the index page
      visit IndexPage do |page|
        # When: input a valid request
        page.search_job_with_skill(EMPTY_KEYWORD)

        # Then: user jumps back to index url
        _(@browser.url).must_match index_url

        # Then: user sees flash bar
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message_element.text.downcase).must_include invalid_query_warning
      end
    end
  end
end
