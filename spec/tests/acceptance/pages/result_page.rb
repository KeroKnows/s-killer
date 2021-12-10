# frozen_string_literal: true

# Page object for result page
class ResultPage
  include PageObject

  page_url "#{Skiller::App.config.APP_HOST}/result?query=<%=params[:query]%>"

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  span(:title, id: 'title')
  unordered_list(:skill_list, id: 'skill_list')
  unordered_list(:salary_list, id: 'salary_list')
  div(:vacancies, id: 'vacancies')
  link(:to_last_page, id: 'to_last_page')

  def skills
    skill_list_element.spans(id: 'skill_name').map(&:text)
  end

  def return_to_index
    to_last_page
  end
end
