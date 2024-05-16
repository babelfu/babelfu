# frozen_string_literal: true

class SyncPullRequestJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  good_job_control_concurrency_with(
    perform_limit: 1,
    enqueue_limit: 2,
    enqueue_throttle: [10, 1.minute],
    key: -> { "#{self.class.name}:project_id:#{arguments.first.id}:pr:#{arguments.second}" }
  )

  queue_as :default

  def perform(project, remote_id)
    pr = project.pull_requests.find_by(remote_id:)
    pr&.sync_in_progress!

    client = project.client
    data = client.pull_request(remote_id)
    pr = UpsertPullRequestFromGithubDataService.call(project, data)
    pr.sync_in_progress!

    # TODO: do it as batch jobs
    FetchBranchTranslations.new(project, branch_name: pr.base_branch_name).fetch!
    FetchBranchTranslations.new(project, branch_name: pr.head_branch_name).fetch!

    pr.sync_done!
  rescue StandardError => e
    pr&.sync_failed!

    raise e
  end
end
