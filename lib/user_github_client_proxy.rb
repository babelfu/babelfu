# frozen_string_literal: true

class UserGithubClientProxy
  include ApiWrapper

  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

  def authentication
    user.authentication
  end

  api_wrapper def _repos
    client.repos
  end

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
