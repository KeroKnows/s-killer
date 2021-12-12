# frozen_string_literal: true

# Page object for result page
class ResultPage
  include PageObject

  page_url "#{Skiller::App.config.TEST_HOST}/result?query=<%=params[:query]%>"

  div(:warning_message, id: 'flash-bar-danger')
  div(:success_message, id: 'flash-bar-success')

  h2(:title, id: 'title')
  unordered_list(:skill_list, id: 'skill-list')
  unordered_list(:salary_list, id: 'salary-list')
  div(:vacancies, id: 'vacancy-box')
  link(:to_last_page, id: 'return-btn')

  def skills
    skill_list_element.spans(class: 'skill-name').map(&:text)
  end

  def return_to_index
    to_last_page
  end
end
