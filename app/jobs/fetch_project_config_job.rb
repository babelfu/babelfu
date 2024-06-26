# frozen_string_literal: true

class FetchProjectConfigJob < ApplicationJob
  queue_as :default

  def perform(project)
    FetchProjectData.new(project).fetch!
    project.config_fetched!
  end
end
