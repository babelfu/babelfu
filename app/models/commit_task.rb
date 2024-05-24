# frozen_string_literal: true

# == Schema Information
#
# Table name: commit_tasks
#
#  id                     :bigint           not null, primary key
#  branch_name            :string
#  commited_at            :datetime
#  ref                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  project_id             :bigint           not null
#  pull_request_remote_id :string
#
# Indexes
#
#  index_commit_tasks_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class CommitTask < ApplicationRecord
  belongs_to :project
  validates :branch_name, presence: true

  after_commit :reload_commit_view

  def reload_commit_view
    broadcast_refresh_to(presenter.commit_view_id)
  end

  def presenter
    @presenter ||= CommitsPresenter.new(project:, branch_name:)
  end

  def commit_proposals
    @commit_proposals ||= CommitProposals.new(project, branch_name)
  end

  def url
    return nil if ref.blank?

    File.join(Babelfu.config.github_domain, project.remote_repository_id, "commit", ref)
  end
end
