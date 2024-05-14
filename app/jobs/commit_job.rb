# frozen_string_literal: true

class CommitJob < ApplicationJob
  queue_as :default

  def perform(commit)
    response = commit.commit_proposals.commit!
    SyncBranchJob.perform_later(commit.project, commit.branch_name)
    commit.update!(ref: response.object.sha, commited_at: Time.current)
  end
end
