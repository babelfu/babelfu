# frozen_string_literal: true

class SyncBranchJob < ApplicationJob
  queue_as :default

  def perform(project, branch_name)
    update_branch_status(project, { name: branch_name, sync_status: "in_progress" })

    FetchBranchTranslations.new(project, branch_name:).fetch!

    update_branch_status(project, { name: branch_name, sync_status: "done", synced_at: Time.current })
  rescue StandardError => e
    update_branch_status(project, { name: branch_name, sync_status: "failed" })
    raise e
  end

  def update_branch_status(project, attrs)
    project.branches.upsert(attrs, unique_by: %i[name project_id])
  end
end
