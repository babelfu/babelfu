# frozen_string_literal: true

class ProjectClient < BaseClient
  attr_reader :project

  def initialize(project)
    @project = project
  end

  api_wrapper def blob(sha)
    client.blob(repo_id, sha)
  end

  api_wrapper def branch(branch_name)
    client.branch(repo_id, branch_name)
  end

  api_wrapper def branches
    client.branches(repo_id)
  end

  api_wrapper def contents(path:, ref:)
    client.contents(repo_id, path: path, ref: ref)
  end

  api_wrapper def create_blob(content, encoding)
    client.create_blob(repo_id, content, encoding)
  end

  api_wrapper def create_tree(tree_content, base_tree:)
    client.create_tree(repo_id, tree_content, base_tree:)
  end

  api_wrapper def create_commit(message, tree_sha, parent_sha)
    client.create_commit(repo_id, message, tree_sha, parent_sha)
  end

  api_wrapper def pull_requests(state: "open")
    client.pull_requests(repo_id, state: state)
  end

  api_wrapper def pull_request(number)
    client.pull_request(repo_id, number)
  end

  api_wrapper def repository
    client.repository(repo_id)
  end

  api_wrapper def tree(sha, recursive: false)
    client.tree(repo_id, sha, recursive: recursive)
  end

  api_wrapper def update_ref(ref, sha)
    client.update_ref(repo_id, ref, sha)
  end

  private

  def repo_id
    @project.remote_repository_id
  end

  def installation_id
    @project.installation_id
  end

  def fetch_access_token_mutex_key
    "project:#{project.id}:fetch_access_token"
  end

  def fetch_and_save_access_token!
    data = GithubAppClient.client.create_app_installation_access_token(installation_id)
    project.update!(github_access_token: data.token, github_access_token_expires_at: data.expires_at)
  end

  def access_token
    project.github_access_token
  end

  def valid_access_token?
    project.github_access_token.present? && project.github_access_token_expires_at > Time.current.utc # The UTC is important
  end
end
