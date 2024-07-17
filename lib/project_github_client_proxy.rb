# frozen_string_literal: true

class ProjectGithubClientProxy
  include ApiWrapper

  attr_reader :project, :authentication

  def initialize(project, authentication)
    @project = project
    @authentication = authentication
  end

  private

  api_wrapper def _blob(sha)
    client.blob(repo_id, sha)
  end

  api_wrapper def _branch(branch_name)
    client.branch(repo_id, branch_name)
  end

  api_wrapper def _branches
    client.branches(repo_id)
  end

  api_wrapper def _contents(path:, ref: nil)
    client.contents(repo_id, path: path, ref: ref)
  end

  api_wrapper def _create_blob(content, encoding)
    client.create_blob(repo_id, content, encoding)
  end

  api_wrapper def _create_tree(tree_content, base_tree:)
    client.create_tree(repo_id, tree_content, base_tree:)
  end

  api_wrapper def _create_commit(message, tree_sha, parent_sha)
    client.create_commit(repo_id, message, tree_sha, parent_sha)
  end

  api_wrapper def _pull_requests(state: "open")
    client.pull_requests(repo_id, state: state)
  end

  api_wrapper def _pull_request(number)
    client.pull_request(repo_id, number)
  end

  api_wrapper def _repository
    client.repository(repo_id)
  end

  api_wrapper def _tree(sha, recursive: false)
    client.tree(repo_id, sha, recursive: recursive)
  end

  api_wrapper def _update_ref(ref, sha)
    client.update_ref(repo_id, ref, sha)
  end

  api_wrapper def _collaborators
    client.collaborators(repo_id)
  end

  def repo_id
    project.remote_repository_id
  end
end
