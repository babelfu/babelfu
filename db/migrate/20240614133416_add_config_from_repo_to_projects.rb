# frozen_string_literal: true

class AddConfigFromRepoToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :config_from_repo, :json, default: {}
  end
end
