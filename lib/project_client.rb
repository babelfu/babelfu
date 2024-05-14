# frozen_string_literal: true

class ProjectClient
  attr_reader :project

  RequestError = Class.new(StandardError)

  class << self
    def with_access_token(method_name)
      original_method = instance_method(method_name)
      define_method(method_name) do |*args, **kwargs, &block|
        # TODO: review the expiration time logic
        build_client if access_token.expires_at < 10.minutes.from_now
        res = original_method.bind(self).call(*args, **kwargs, &block)
        # TODO: rescue expired token and retry
        # TODO: handle rate limit exceeded
        # TODO: I would like to specify the success code per method
        raise RequestError, res.inspect unless client.last_response.status.in?([200, 201])

        res
      end
    end
  end

  def initialize(project)
    @project = project
  end

  with_access_token def blob(sha)
    client.blob(repo_id, sha)
  end

  with_access_token def branch(branch_name)
    client.branch(repo_id, branch_name)
  end

  with_access_token def branches
    client.branches(repo_id)
  end

  with_access_token def contents(path:, ref:)
    client.contents(repo_id, path: path, ref: ref)
  end

  with_access_token def create_blob(content, encoding)
    client.create_blob(repo_id, content, encoding)
  end

  with_access_token def create_tree(tree_content, base_tree:)
    client.create_tree(repo_id, tree_content, base_tree:)
  end

  with_access_token def create_commit(message, tree_sha, parent_sha)
    client.create_commit(repo_id, message, tree_sha, parent_sha)
  end

  with_access_token def pull_requests(state: "open")
    client.pull_requests(repo_id, state: state)
  end

  with_access_token def pull_request(number)
    client.pull_request(repo_id, number)
  end

  with_access_token def repository
    client.repository(repo_id)
  end

  with_access_token def tree(sha, recursive: false)
    client.tree(repo_id, sha, recursive: recursive)
  end

  with_access_token def update_ref(ref, sha)
    client.update_ref(repo_id, ref, sha)
  end

  def repo_id
    @project.remote_repository_id
  end

  def installation_id
    @project.installation_id
  end

  def client
    @client || build_client
  end

  def build_client
    @client = Octokit::Client.new(access_token: access_token.token)
  end

  def access_token
    # TODO: makes sense to cache the token between requests?
    @access_token ||= fetch_access_token!
  end

  def fetch_access_token!
    @access_token = GithubAppClient.client.create_app_installation_access_token(installation_id)
  end
end
