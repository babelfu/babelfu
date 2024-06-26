class AddUseConfigFromRepoToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :use_config_from_repo, :boolean, default: false, null: false
  end
end
