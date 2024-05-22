# frozen_string_literal: true

class SyncProjectJob < ApplicationJob
  queue_as :default

  def perform(project)
    project.sync_in_progress!
    client = project.client
    data = client.repository
    attrs = { default_branch_name: data.default_branch }
    project.update!(attrs)

    project.default_branch!.enqueue_sync!
    FetchBranches.new(project).fetch!
    FetchPullRequests.new(project).fetch!
    project.sync_done!
  rescue StandardError => e
    project.sync_failed!
    raise e
  end
end
