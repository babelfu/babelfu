# frozen_string_literal: true

class CreateMetadataProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :metadata_projects do |t|
      t.references :project, null: false, foreign_key: true
      t.json :github_collaborators, default: []

      t.timestamps
    end
  end
end
