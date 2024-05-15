# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_requests
#
#  id               :bigint           not null, primary key
#  base_branch_name :string
#  head_branch_name :string
#  state            :string
#  sync_status      :string
#  synced_at        :datetime
#  title            :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_id       :bigint           not null
#  remote_id        :string
#  repository_id    :string
#
# Indexes
#
#  index_pull_requests_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class PullRequest < ApplicationRecord
  belongs_to :project

  def to_param
    remote_id
  end

  def enqueue_sync!
    sync_in_progress!
    SyncPullRequestJob.perform_later(project_id, remote_id)
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
    broadcast_update(renderable: SyncPullRequestWidgetComponent.new(self))
  end
end
