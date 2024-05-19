# frozen_string_literal: true

require "test_helper"

class PullRequestTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "#base_branch" do
    project1 = Project.create!(remote_repository_id: "repo1", default_branch_name: "master")
    project2 = Project.create!(remote_repository_id: "repo2", default_branch_name: "master")

    project1_branch = project1.branches.create!(name: "master")
    _project2_branch = project2.branches.create!(name: "master")

    pull_request1 = PullRequest.create!(project: project1, remote_id: 1, base_branch_name: "master", head_branch_name: "feature")
    assert_equal project1_branch, pull_request1.base_branch
  end

  test "#head_branch" do
    project1 = Project.create!(remote_repository_id: "repo1", default_branch_name: "master")
    project2 = Project.create!(remote_repository_id: "repo2", default_branch_name: "master")

    project1_branch = project1.branches.create!(name: "feature")
    _project2_branch = project2.branches.create!(name: "feature")

    pull_request1 = PullRequest.create!(project: project1, remote_id: 1, head_branch_name: "feature", base_branch_name: "master")
    assert_equal project1_branch, pull_request1.head_branch
  end

  test "#to_param" do
    pull_request = PullRequest.new(remote_id: 123)
    assert_equal "123", pull_request.to_param
  end

  test "#enqueue_sync!" do
    pull_request = pull_requests(:one_one)
    assert_enqueued_with(job: SyncPullRequestJob) do
      pull_request.enqueue_sync!
    end

    assert pull_request.sync_in_progress?
  end

  test "#broascast_update_sync_status" do
    pull_request = pull_requests(:one_one)
    assert_turbo_stream_broadcasts(pull_request) do
      pull_request.broadcast_update_sync_status
    end
  end

  test "#sync_ref" do
    pull_request = pull_requests(:one_one)
    assert_equal "master-ref:feature-ref", pull_request.sync_ref
  end
end
