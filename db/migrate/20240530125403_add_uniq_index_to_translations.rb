# frozen_string_literal: true

class AddUniqIndexToTranslations < ActiveRecord::Migration[7.1]
  def change
    add_index :translations, %i[project_id key locale value], unique: true
  end
end
