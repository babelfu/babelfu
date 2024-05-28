# frozen_string_literal: true

class UserClient < BaseClient
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def fetch_and_save_access_token!
    data = GithubAppClient.generate_access_token_from_refresh_token(user.github_refresh_token)
    user.save_github_access_token!(data)
  end

  def valid_access_token?
    access_token.present? && user.github_access_token_expires_at.present? && user.github_access_token_expires_at > Time.current
  end

  def fetch_access_token_mutex_key
    "user:#{user.id}:fetch_access_token"
  end

  def access_token
    user.github_access_token
  end

  private

  api_wrapper def _find_installation_repositories_for_user(installation_id)
    client.find_installation_repositories_for_user(installation_id)
  end

  api_wrapper def _find_user_installations
    client.find_user_installations
  end

  api_wrapper def _github_user
    client.user
  end
end
