# frozen_string_literal: true

class CommitJob < ApplicationJob
  queue_as :default

  def self.enqueue_batch(commit_task)
    GoodJob::Batch.enqueue(on_finish: CommitJob, commit_task:)
  end

  rescue_from(Octokit::UnprocessableEntity) do |exception|
    retry_job queue: :default, exception: exception, max_attempts: 3
  end

  def perform(batch, _options)
    commit_task = batch.properties[:commit_task]
    project = commit_task.project
    branch_name = commit_task.branch_name

    if batch.properties[:stage].nil?
      # we need to sync the branch first, in the callback we will commit the proposals
      batch.enqueue(stage: 1) do
        SyncBranchBatchJob.perform_later(project, branch_name)
      end

    elsif batch.properties[:stage] == 1
      # we need to update the branch with the remote ref
      SyncBranchBatchJob.update_branch!(batch, project, branch_name)

      # now we can commit the proposals
      response = commit_task.commit_proposals.commit!
      # and sync the branch again, in the callback we will update the commit task
      batch.enqueue(stage: 2, ref: response.object.sha, commited_at: Time.current) do
        SyncBranchBatchJob.perform_later(project, commit_task.branch_name)
      end

    elsif batch.properties[:stage] == 2
      # we need to update the branch with the remote ref
      SyncBranchBatchJob.update_branch!(batch, project, branch_name)

      # finally we can update the commit task with the new ref and commited_at
      ref = batch.properties[:ref]
      commited_at = batch.properties[:commited_at]
      commit_task.update!(ref: ref, commited_at: commited_at)
    end
  end
end
