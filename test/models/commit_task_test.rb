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
require "test_helper"

class CommitTaskTest < ActiveSupport::TestCase
  test "#url when ref is nil" do
    commit_task = CommitTask.new(project: projects(:one), branch_name: "feature")
    assert_nil commit_task.url
  end

  test "#url when ref is not nil" do
    project = projects(:one)
    commit_task = CommitTask.new(project: project, ref: "456", branch_name: "feature")
    assert_equal "#{Babelfu.config.github_domain}/#{project.remote_repository_id}/commit/456", commit_task.url
  end
end
