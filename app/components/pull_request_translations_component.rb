# frozen_string_literal: true

class PullRequestTranslationsComponent < BaseTranslationsComponent
  attr_reader :pull_request, :translations_presenter

  def initialize(pull_request, translations_presenter)
    @pull_request = pull_request
    @translations_presenter = translations_presenter
  end

  def filter_path
    project_pull_request_path(project, pull_request)
  end

  def clear_path
    project_pull_request_path(project, pull_request, query_params_without_filter)
  end

  delegate :project, to: :pull_request
end
