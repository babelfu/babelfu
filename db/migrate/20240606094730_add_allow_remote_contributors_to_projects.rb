# frozen_string_literal: true

class AddAllowRemoteContributorsToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :allow_remote_contributors, :boolean, default: false, null: false
  end
end
