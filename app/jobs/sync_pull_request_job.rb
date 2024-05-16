# frozen_string_literal: true

class SyncPullRequestJob < ApplicationJob
  queue_as :default

  def perform(project_id, remote_id)
    project = Project.find(project_id)

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
