# frozen_string_literal: true

class RemoveSyncFieldsFromProjectBranchAndPullRequests < ActiveRecord::Migration[7.1]
  def change
    remove_column :projects, :sync_status, :string
    remove_column :projects, :synced_at, :datetime

    remove_column :branches, :sync_status, :string
    remove_column :branches, :synced_at, :datetime

    remove_column :pull_requests, :sync_status, :string
    remove_column :pull_requests, :synced_at, :datetime
  end
end
