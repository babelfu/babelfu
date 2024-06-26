# frozen_string_literal: true

module Syncable
  extend ActiveSupport::Concern

  included do
    has_one :sync_state, as: :syncable, dependent: :delete
    lazy_has_one :sync_state
  end

  delegate :synced_at, to: :sync_state

  def sync_status
    sync_state.status
  end

  def change_ref_after_sync?
    sync_state.ref_before_sync != sync_state.ref_after_sync
  end

  def sync_in_progress?
    sync_status == "in_progress"
  end

  def sync_done?
    sync_status == "done"
  end

  def sync_failed?
    sync_status == "failed"
  end

  def sync_in_progress!
    return if sync_in_progress?

    sync_state.update!(status: "in_progress", ref_before_sync: sync_ref)
    broadcast_update_sync_status
  end

  def sync_done!
    return if sync_done?

    sync_state.update!(status: "done", synced_at: Time.current, ref_after_sync: sync_ref)
    broadcast_update_sync_status
  end

  def sync_failed!
    return if sync_failed?

    sync_state.update!(status: "failed")
    broadcast_update_sync_status
  end

  # You can override these methods in your model
  def sync_ref
    updated_at
  end

  def broadcast_update_sync_status; end
end
