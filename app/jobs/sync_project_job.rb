# frozen_string_literal: true

class SyncProjectJob < ApplicationJob
  queue_as :default

  def perform(project)
    project.sync_in_progress!

    FetchProjectData.new(project).fetch!
    project.default_branch!.enqueue_sync!
    FetchBranches.new(project).fetch!
    FetchPullRequests.new(project).fetch!
    project.sync_done!
  rescue StandardError => e
    project.sync_failed!
    raise e
  end
end
