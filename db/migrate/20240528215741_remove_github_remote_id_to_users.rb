# frozen_string_literal: true

class RemoveGithubRemoteIdToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :github_remote_id, :string
  end
end
