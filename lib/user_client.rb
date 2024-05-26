# frozen_string_literal: true

class UserClient < BaseClient
  attr_reader :user

  def initialize(user)
    @user = user
  end

  api_wrapper delegate :find_installation_repositories_for_user,
                       :find_user_installations,
                       to: :client

  api_wrapper def github_user
    client.user
  end

  private

  def fetch_access_token_mutex_key
    "user:#{user.id}:fetch_access_token"
  end

  def fetch_and_save_access_token!
    data = GithubAppClient.generate_access_token_from_refresh_token(user.github_refresh_token)
    user.save_github_access_token!(data)
  end

  def access_token
    user.github_access_token
  end

  def valid_access_token?
    user.github_access_token.present? && user.github_access_token_expires_at > Time.current
  end
end
