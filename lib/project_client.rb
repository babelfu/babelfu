# frozen_string_literal: true

class ProjectClient
  attr_reader :project

  MAX_TIME_TO_WAIT_FOR_LOCK = 2
  RequestError = Class.new(StandardError)

  class << self
    def with_access_token(method_name)
      original_method = instance_method(method_name)
      define_method(method_name) do |*args, **kwargs, &block|
        retried = false
        # TODO: review if we want to enqueue a job to refresh the token if
        # it's about to expire
        res = original_method.bind(self).call(*args, **kwargs, &block)
        # TODO: handle rate limit exceeded
        # TODO: I would like to specify the success code per method
        raise RequestError, res.inspect unless client.last_response.status.in?([200, 201])

        res
      rescue Octokit::Unauthorized => e
        # An unauthorized request could be due to an expired token
        # so we try to refresh the token and retry the request only once
        Rails.logger.error("Unauthorized request: #{e.message}")
        if retried
          rasise e
        else
          retried = true
          build_client(force: true)
          retry
        end
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

  def build_client(force: false)
    @client = Octokit::Client.new(access_token: fetch_access_token!(force:))
  end

  def fetch_access_token!(force: false)
    # We just return the access token if it's valid and we are not forcing
    # We would like to force it when the request fails with an Unauthorized error
    return access_token if !force && valid_access_token?

    # We use an advisory lock to avoid multiple requests to fetch the access token
    # at the same time. For example when syncing a branch, it trigger multiple
    # SyncBranchFileJob
    ActiveRecord::Base.with_advisory_lock!("fetch_access_token:#{project.id}", MAX_TIME_TO_WAIT_FOR_LOCK) do
      # Becuase we could be waiting for the lock, maybe the token was already fetched
      # by another process, so we check again if the token is valid before fetching it
      # again and we return it if it's valid unless we are forcing it.
      return access_token if !force && valid_access_token?

      data = GithubAppClient.client.create_app_installation_access_token(installation_id)
      project.update!(github_access_token: data.token, github_access_token_expires_at: data.expires_at)
      access_token
    end
  end

  def access_token
    project.github_access_token
  end

  def valid_access_token?
    project.github_access_token.present? && project.github_access_token_expires_at > Time.current.utc # The UTC is important
  end
end
