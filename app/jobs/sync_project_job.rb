# frozen_string_literal: true

class SyncProjectJob < ApplicationJob
  queue_as :default

  def perform(project)
    project.update!(sync_status: "in_progress")
    client = project.client
    data = client.repository
    attrs = { default_branch_name: data.default_branch }
    project.update!(attrs)

    FetchBranches.new(project).fetch!
    FetchPullRequests.new(project).fetch!
    project.update!(sync_status: "done", synced_at: Time.current)
  rescue StandardError => e
    project.update!(sync_status: "failed")
    raise e
  end
end
