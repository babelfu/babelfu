# frozen_string_literal: true

class CommitJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  good_job_control_concurrency_with(
    perform_limit: 1,
    enqueue_limit: 2,
    enqueue_throttle: [10, 1.minute],
    key: lambda do
      commit = arguments.first
      project_id = commit.project_id
      branch_name = commit.branch_name

      "#{self.class.name}:project_id:#{project_id}:branch_name:#{branch_name}"
    end
  )

  queue_as :default

  def perform(commit)
    response = commit.commit_proposals.commit!
    SyncBranchJob.perform_later(commit.project, commit.branch_name)
    commit.update!(ref: response.object.sha, commited_at: Time.current)
  end
end
