# frozen_string_literal: true

# == Schema Information
#
# Table name: branches
#
#  id         :bigint           not null, primary key
#  name       :string
#  ref        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint           not null
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
  include Syncable
  belongs_to :project

  has_many :translations, ->(x) { where(project_id: x.project_id, branch_ref: x.ref) }, foreign_key: :branch_name, primary_key: :name
  has_one :sync_state, as: :syncable, dependent: :delete

  validates :name, presence: true, uniqueness: { scope: :project_id }

  def to_param
    name
  end

  def url
    File.join(Babelfu.config.github_domain, project.remote_repository_id, "tree", name)
  end

  def enqueue_sync!
    sync_in_progress!
    SyncBranchJob.enqueue_batch(project, name)
  end

  def broadcast_update_sync_status
    broadcast_update(renderable: SyncBranchWidgetComponent.new(self, live: true))
  end

  def sync_ref
    ref
  end
end
