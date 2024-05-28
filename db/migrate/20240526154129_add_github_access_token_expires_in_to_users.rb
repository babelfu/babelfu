# frozen_string_literal: true

class AddGithubAccessTokenExpiresInToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :github_access_token_expires_at, :datetime
    add_column :users, :github_refresh_token_expires_at, :datetime

    remove_column :users, :github_refresh_token_expires_in, :integer
  end
end
