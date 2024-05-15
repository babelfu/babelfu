# frozen_string_literal: true

class SyncBranchJob < ApplicationJob
  queue_as :default

  def perform(project, branch_name)
    branch = project.branches.find_or_create_by!(name: branch_name)
    branch.update!(sync_status: "in_progress")

    FetchBranchTranslations.new(project, branch_name:).fetch!
    branch.update!(sync_status: "done", synced_at: Time.current)
  rescue StandardError => e
    branch.update!(sync_status: "failed")
    raise e
  end
end
