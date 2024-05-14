# frozen_string_literal: true

class ConnectionsController < ApplicationController
  def show; end

  def disconnect_github
    current_user.clear_github_connection!
    redirect_to connections_path
  end

  def github_callback
    code = params["code"]
    oauth = GithubAppClient.exchange_code(code)
    current_user.save_github_access_token!(oauth)
    FetchGithubUserMetadataJob.perform_later(current_user)
    redirect_to connections_path
  end
end
