# frozen_string_literal: true

class AccountsController < ApplicationController
  def show; end

  def request_sync
    FetchGithubUserMetadataJob.perform_later(current_user)
    redirect_to account_path, notice: "Sync requested"
  end
end
