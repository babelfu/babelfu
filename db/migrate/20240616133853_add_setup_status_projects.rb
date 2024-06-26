# frozen_string_literal: true

class AddSetupStatusProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :setup_status, :integer, default: 0, null: false
  end
end
