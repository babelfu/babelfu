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
require "test_helper"

class BranchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "#translations filter by project_id, branch_name and branch_ref" do
    project1 = Project.create!(remote_repository_id: "user/repo1", default_branch_name: "master")
    project2 = Project.create!(remote_repository_id: "user/repo2", default_branch_name: "master")

    branch11 = project1.branches.create!(name: "master", ref: "11")
    _branch12 = project1.branches.create!(name: "develop", ref: "12")
    _branch21 = project2.branches.create!(name: "master", ref: "21")

    translation111a = project1.translations.create!(branch_name: "master", branch_ref: "11")
    _translation111b = project1.translations.create!(branch_name: "master", branch_ref: "11b")
    _translation112 = project1.translations.create!(branch_name: "develop", branch_ref: "12")
    _translation211 = project2.translations.create!(branch_name: "master", branch_ref: "21")

    assert_equal [translation111a], branch11.translations
  end

  test "#to_param" do
    branch = Branch.new(name: "master")
    assert_equal "master", branch.name
  end

  test "#url" do
    project = projects(:one)
    branch = project.branches.build(name: "master")
    assert_equal "#{Babelfu.config.github_domain}/#{project.remote_repository_id}/tree/master", branch.url
  end

  test "#enqueue_sync!" do
    branch = branches(:one_master)
    assert_enqueued_with(job: SyncBranchJob) do
      branch.enqueue_sync!
    end

    assert branch.sync_in_progress?
  end

  test "#broadcast_update_sync_status" do
    branch = branches(:one_master)
    assert_turbo_stream_broadcasts(branch) do
      branch.broadcast_update_sync_status
    end
  end

  test "#sync_ref" do
    branch = Branch.new(ref: "foo")
    assert_equal "foo", branch.sync_ref
  end
end
