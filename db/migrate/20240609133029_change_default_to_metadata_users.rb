# frozen_string_literal: true

class ChangeDefaultToMetadataUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :metadata_users, :github_repositories, from: nil, to: {}
    change_column_null :metadata_users, :github_repositories, false, {}
    change_column_default :metadata_users, :github_user, from: nil, to: {}
    change_column_null :metadata_users, :github_user, false, {}
    change_column_default :metadata_users, :github_installations, from: nil, to: []
    change_column_null :metadata_users, :github_installations, false, []
  end
end
