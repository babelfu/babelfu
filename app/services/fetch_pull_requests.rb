# frozen_string_literal: true

class FetchPullRequests
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def fetch!
    remote_pull_requests = client.pull_requests(state: "open")

    remote_pull_requests.each do |data|
      UpsertPullRequestFromGithubDataService.call(project, data)
    end

    # TODO: what to do with closed pull requests?
    project.pull_requests.where.not(remote_id: remote_pull_requests.map(&:number)).update_all(state: "closed")
  end

  delegate :client, to: :project
end
