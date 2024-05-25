# frozen_string_literal: true

class AddGithubAccessTokenToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :github_access_token, :string
    add_column :projects, :github_access_token_expires_at, :datetime
  end
end
