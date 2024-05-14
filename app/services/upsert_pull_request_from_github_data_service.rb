# frozen_string_literal: true

class UpsertPullRequestFromGithubDataService
  def self.call(project, data)
    pr = project.pull_requests.find_or_initialize_by(remote_id: data.number)
    pr.title = "##{data.number} #{data.title}"
    pr.remote_id = data.number
    pr.url = data.html_url
    pr.head_branch_name = data.head.ref
    pr.base_branch_name = data.base.ref
    pr.repository_id = data.head.repo.id
    pr.state = data.state
    pr.save!
    pr
  end
end
