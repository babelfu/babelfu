# frozen_string_literal: true

class SyncPullRequestWidgetComponent < SyncWidgetComponent
  delegate :project, to: :object

  def sync_path
    sync_project_pull_request_path(project, object)
  end

  def title
    "Sync translations"
  end
end
