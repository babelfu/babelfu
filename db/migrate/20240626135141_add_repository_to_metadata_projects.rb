# frozen_string_literal: true

class AddRepositoryToMetadataProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :metadata_projects, :repository, :json, default: {}
  end
end
