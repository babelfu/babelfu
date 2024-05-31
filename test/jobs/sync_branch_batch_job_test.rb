# frozen_string_literal: true

require "test_helper"

class SyncBranchBatchJobTest < ActiveSupport::TestCase
  test "mark sync as failed if any exception is raised" do
    project = Project.create(remote_repository_id: "foo/bar")
    branch_name = "master"

    FetchTranslations.stubs(:new).raises(StandardError)

    assert_raises(StandardError) do
      SyncBranchBatchJob.perform_now(project, branch_name)
    end

    project.branches.find_by(name: branch_name).tap do |branch|
      assert branch.sync_failed?
    end
  end
end
