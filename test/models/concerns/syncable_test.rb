# frozen_string_literal: true

class SyncableTest < ActiveSupport::TestCase
  ActiveRecord::Migration.create_table :dummy_syncable_models, force: true do |t|
    t.string :name
    t.timestamps
  end

  def setup
    @model = DummySyncableModel.create
  end

  test "#sync_state" do
    assert @model.sync_state
  end

  test "states" do
    assert_equal "not_synced", @model.sync_status

    assert_difference -> { @model.broadcasted_count }, 1 do
      @model.sync_in_progress!
    end
    assert_equal "0", @model.sync_state.ref_before_sync
    assert @model.sync_in_progress?

    assert_difference -> { @model.broadcasted_count }, 1 do
      @model.sync_done!
    end
    assert_equal "1", @model.sync_state.ref_after_sync
    assert @model.sync_done?

    assert_difference -> { @model.broadcasted_count }, 1 do
      @model.sync_failed!
    end
    assert @model.sync_failed?
  end

  test "#change_ref_after_sync?" do
    @model.sync_state.ref_before_sync = "1"
    @model.sync_state.ref_after_sync = "2"

    assert @model.change_ref_after_sync?

    @model.sync_state.ref_before_sync = "2"
    @model.sync_state.ref_after_sync = "2"

    assert_not @model.change_ref_after_sync?
  end

  class DummySyncableModel < ApplicationRecord
    self.table_name = "dummy_syncable_models"
    include Syncable

    def broadcast_update_sync_status
      @broadcasted_count ||= 0
      @broadcasted_count += 1
    end

    def broadcasted_count
      @broadcasted_count || 0
    end

    def sync_ref
      broadcasted_count
    end
  end
end
