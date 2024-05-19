# frozen_string_literal: true

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
