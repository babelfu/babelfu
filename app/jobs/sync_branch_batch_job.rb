# frozen_string_literal: true

class SyncBranchBatchJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Batches

  def perform(project, branch_name)
    branch = project.branches.find_or_create_by!(name: branch_name)
    branch.sync_in_progress!
    service = FetchTranslations.new(project, branch_name)
    if service.need_sync?
      batch.enqueue(remote_branch_ref: service.remote_branch_ref) do
        service.source_files.each do |source_file|
          SyncBranchFileJob.perform_later(project:, branch_name:, branch_ref: service.remote_branch_ref, file_path_ref: source_file.sha, file_path: source_file.path)
        end
      end
    end
  end

  def self.update_branch!(batch, project, branch_name)
    branch = project.branches.find_by!(name: branch_name)
    remote_branch_ref = batch.properties[:remote_branch_ref]
    if remote_branch_ref
      branch.ref = remote_branch_ref
      branch.save!
    end

    branch.sync_done!
  end
end
