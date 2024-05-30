# frozen_string_literal: true

class RemoveBranchNameFromTranslations < ActiveRecord::Migration[7.1]
  def change
    remove_column :translations, :branch_name, :string
    remove_column :translations, :branch_ref, :string
  end
end
