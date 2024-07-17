# frozen_string_literal: true

class InstallationGithubAuthentication
  include ClientToken
  # maybe we should create the installation model
  # and store the tokens there instead of in the project
  attr_reader :project

  def initialize(project)
    @project = project
    build_client
  end

  delegate :installation_id, to: :project

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
    project.github_access_token.present? && project.github_access_token_expires_at.present? && project.github_access_token_expires_at > Time.current.utc # The UTC is important
  end
end
