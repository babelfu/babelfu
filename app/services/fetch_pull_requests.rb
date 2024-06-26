# frozen_string_literal: true

class FetchPullRequests
  attr_reader :project

  def initialize(project)
    @project = project
  end

  def fetch!
    remote_pull_requests = client.pull_requests(state: "open")
    remote_pull_requests = remote_pull_requests.select { |pr| pr.head.repo.fork == false && pr.base.repo.fork == false }

    remote_pull_requests.each do |data|
      UpsertPullRequestFromGithubDataService.call(project, data)
    end

    # TODO: what to do with closed pull requests?
    project.pull_requests.where.not(remote_id: remote_pull_requests.map(&:number)).delete_all
  end

  delegate :client, to: :project
end
