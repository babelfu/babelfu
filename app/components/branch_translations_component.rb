# frozen_string_literal: true

class BranchTranslationsComponent < BaseTranslationsComponent
  attr_reader :branch, :translations_presenter

  def initialize(branch, translations_presenter)
    @branch = branch
    @translations_presenter = translations_presenter
  end

  def filter_path
    project_branch_path(project, branch)
  end

  def clear_path
    project_branch_path(project, branch, query_params_without_filter)
  end

  delegate :project, to: :branch
end
