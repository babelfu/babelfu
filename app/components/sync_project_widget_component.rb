# frozen_string_literal: true

class SyncProjectWidgetComponent < SyncWidgetComponent
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def object
    project
  end

  def sync_path
    sync_project_path(project)
  end

  def title
    "Sync project"
  end
end
