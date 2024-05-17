# frozen_string_literal: true

class SyncProjectJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  good_job_control_concurrency_with(
    perform_limit: 1,
    enqueue_limit: 2,
    enqueue_throttle: [10, 1.minute],
    key: -> { "#{self.class.name}:project_id:#{arguments.first.id}" }
  )

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
