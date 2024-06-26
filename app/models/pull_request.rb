# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_requests
#
#  id               :bigint           not null, primary key
#  base_branch_name :string
#  head_branch_name :string
#  state            :string
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
  include Syncable

  belongs_to :project
  has_one :base_branch, ->(x) { where(project_id: x.project_id) }, foreign_key: :name, primary_key: :base_branch_name, class_name: "Branch"
  lazy_has_one :base_branch

  has_one :head_branch, ->(x) { where(project_id: x.project_id) }, foreign_key: :name, primary_key: :head_branch_name, class_name: "Branch"
  lazy_has_one :head_branch

  validates :remote_id, presence: true
  validates :base_branch_name, presence: true
  validates :head_branch_name, presence: true
  # validates :repository_id, presence: true TODO: we may want to remove this field

  def name
    title
  end

  def to_param
    remote_id
  end

  def enqueue_sync!
    sync_in_progress!
    SyncPullRequestJob.enqueue_batch(project, remote_id)
  end

  def sync_ref
    "#{base_branch.ref}:#{head_branch.ref}"
  end

  def broadcast_update_sync_status
    broadcast_update(renderable: SyncPullRequestWidgetComponent.new(self, live: true))
  end
end
