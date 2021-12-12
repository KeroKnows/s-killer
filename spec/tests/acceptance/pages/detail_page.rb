# frozen_string_literal: true

# Page object for detail page
class DetailPage
  include PageObject

  page_url "#{Skiller::App.config.TEST_HOST}/detail/<%=params[:job_id]%>"

  h1(:title, id: 'job-title')
  div(:meta_box, id: 'job-meta-box')
  div(:info_box, id: 'job-info-box')
end
