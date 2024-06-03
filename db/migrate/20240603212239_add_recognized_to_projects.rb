class AddRecognizedToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :recognized, :boolean, default: false, null: false
  end
end
