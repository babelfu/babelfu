# frozen_string_literal: true

class CreateSyncStates < ActiveRecord::Migration[7.1]
  def change
    create_table :sync_states do |t|
      t.references :syncable, polymorphic: true, index: { :unique => true }, null: false
      t.string :status, null: false, default: "not_synced"
      t.string :ref_before_sync
      t.string :ref_after_sync
      t.datetime :synced_at

      t.timestamps
    end
  end
end
