# frozen_string_literal: true

# Page object for index page
class IndexPage
  include PageObject

  page_url Skiller::App.config.TEST_HOST

  div(:warning_message, id: 'flash-bar-danger')
  div(:success_message, id: 'flash-bar-success')

  text_field(:query_search, name: 'query')
  text_area(:skill_search, name: 'skills')
  button(:skill_submit, type: 'submit', id: 'skill-search-submit')
  button(:job_submit, type: 'submit', id: 'job-search-submit')

  def search_skill_with_query(query)
    self.query_search = query
    skill_submit
  end

  def search_job_with_skill(skill_list)
    self.skill_search = skill_list
    job_submit
  end
end
