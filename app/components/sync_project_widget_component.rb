# frozen_string_literal: true

class SyncProjectWidgetComponent < SyncWidgetComponent
  def sync_path
    sync_project_path(object)
  end

  def title
    "Sync project"
  end
end
