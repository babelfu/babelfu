# frozen_string_literal: true

class SyncPullRequestJob < ApplicationJob
  queue_as :default

  def self.enqueue_batch(project, remote_id)
    GoodJob::Batch.enqueue(on_finish: SyncPullRequestJob, project:, remote_id:)
  end

  def perform(batch, _options)
    project = batch.properties[:project]
    remote_id = batch.properties[:remote_id]
    pr = project.pull_requests.find_by(remote_id:)

    if batch.properties[:stage].nil?
      # enqueue the sync branch job for the base branch
      batch.enqueue(stage: 1) do
        SyncBranchBatchJob.perform_later(project, pr.base_branch_name)
      end
    elsif batch.properties[:stage] == 1
      # and update the branch with the remote ref
      SyncBranchBatchJob.update_branch!(batch, project, pr.base_branch_name)

      # enqueue the sync branch job for the head branch
      batch.enqueue(stage: 2) do
        SyncBranchBatchJob.perform_later(project, pr.head_branch_name)
      end
    elsif batch.properties[:stage] == 2

      # and update the branch with the remote ref
      SyncBranchBatchJob.update_branch!(batch, project, pr.head_branch_name)

      # finally mark the pull request as synced
      pr&.sync_done!
    end
  rescue StandardError => e
    pr&.sync_failed!

    raise e
  end
end
