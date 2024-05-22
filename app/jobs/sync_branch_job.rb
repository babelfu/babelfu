# frozen_string_literal: true

class SyncBranchJob < ApplicationJob
  queue_as :default

  def self.enqueue_batch(project, branch_name)
    GoodJob::Batch.enqueue(on_finish: SyncBranchJob, project:, branch_name:)
  end

  def perform(batch, _options)
    project = batch.properties[:project]
    branch_name = batch.properties[:branch_name]

    if batch.properties[:stage].nil?
      # enqueue the actual job that sync the branch
      batch.enqueue(stage: 1) do
        SyncBranchBatchJob.perform_later(project, branch_name)
      end

    elsif batch.properties[:stage] == 1
      SyncBranchBatchJob.update_branch!(batch, project, branch_name)
    end
  rescue StandardError => e
    branch = project.branches.find_by(name: branch_name)
    branch&.sync_failed!

    raise e
  end
end
