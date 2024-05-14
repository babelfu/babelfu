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
  has_many :translations, foreign_key: :branch_ref, primary_key: :ref

  broadcasts_refreshes

  def to_param
    name
  end

  def url
    "https://github.com/#{project.remote_repository_id}/tree/#{name}"
  end

  def enqueue_sync!
    update!(sync_status: "in_progress")
    SyncBranchJob.perform_later(project, name)
  end
end
