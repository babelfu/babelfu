# frozen_string_literal: true

class AddBranchesAndRefsAsArraysToTranslations < ActiveRecord::Migration[7.1]
  def change
    add_column :translations, :branch_refs, :string, array: true, default: []
  end
end
