# frozen_string_literal: true

class AddUniqIndexOnTranslations < ActiveRecord::Migration[7.1]
  def change
    Translation.delete_all
    Branch.update_all(ref: nil)
    add_index :translations, [:project_id, :key, :locale, :branch_ref], unique: true
  end
end
