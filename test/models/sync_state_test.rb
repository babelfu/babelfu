# frozen_string_literal: true

# == Schema Information
#
# Table name: sync_states
#
#  id              :bigint           not null, primary key
#  ref_after_sync  :string
#  ref_before_sync :string
#  status          :string           default("not_synced"), not null
#  syncable_type   :string           not null
#  synced_at       :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  syncable_id     :bigint           not null
#
# Indexes
#
#  index_sync_states_on_syncable  (syncable_type,syncable_id) UNIQUE
#
require "test_helper"

class SyncStateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
