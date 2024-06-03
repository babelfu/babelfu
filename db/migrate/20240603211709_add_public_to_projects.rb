class AddPublicToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :public, :boolean, default: false
  end
end
