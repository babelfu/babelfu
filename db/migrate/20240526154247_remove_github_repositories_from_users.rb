# frozen_string_literal: true

class RemoveGithubRepositoriesFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :github_repositories, :json
  end
end
