# frozen_string_literal: true

# == Schema Information
#
# Table name: branches
#
#  id          :bigint           not null, primary key
#  name        :string
#  ref         :string
#  sync_status :string           default("not_synced")
#  synced_at   :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#
# Indexes
#
#  index_branches_on_name_and_project_id  (name,project_id) UNIQUE
#  index_branches_on_project_id           (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class Branch < ApplicationRecord
  belongs_to :project
  has_many :translations, ->(x) { where(project_id: x.project_id) }, foreign_key: :branch_ref, primary_key: :ref

  def to_param
    name
  end

  def url
    "https://github.com/#{project.remote_repository_id}/tree/#{name}"
  end

  def enqueue_sync!
    sync_in_progress!
    SyncBranchJob.perform_later(project, name)
  end

  def sync_in_progress!
    update!(sync_status: "in_progress")
    broadcast_update_sync_status!
  end

  def sync_done!
    update!(sync_status: "done", synced_at: Time.zone.now)
    broadcast_update_sync_status!
  end

  def sync_failed!
    update!(sync_status: "failed")
    broadcast_update_sync_status!
  end

  def broadcast_update_sync_status!
    broadcast_update(renderable: SyncBranchWidgetComponent.new(self))
  end
end
