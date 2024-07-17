# frozen_string_literal: true

class AddSlugToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :slug, :string
    add_index :projects, :slug, unique: true
  end
end
