class AddConfigFromRepoToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :config_from_repo, :boolean, default: false, null: false
  end
end
