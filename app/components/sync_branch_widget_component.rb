# frozen_string_literal: true

class SyncBranchWidgetComponent < SyncWidgetComponent
  delegate :project, to: :object

  def sync_path
    sync_project_branch_path(project, object)
  end

  def title
    "Sync translations"
  end
end
