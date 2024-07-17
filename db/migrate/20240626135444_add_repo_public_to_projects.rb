class AddRepoPublicToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :repo_public, :boolean, null: false, default: false
  end
end
