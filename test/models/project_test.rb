# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id                             :bigint           not null, primary key
#  allow_remote_contributors      :boolean          default(FALSE), not null
#  config_from_repo               :json
#  default_branch_name            :string
#  default_locale                 :string
#  github_access_token            :string
#  github_access_token_expires_at :datetime
#  name                           :string
#  public                         :boolean          default(FALSE)
#  recognized                     :boolean          default(FALSE), not null
#  repo_public                    :boolean          default(FALSE), not null
#  setup_status                   :integer          default("pending"), not null
#  slug                           :string
#  translations_path              :string
#  use_config_from_repo           :boolean          default(FALSE), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  installation_id                :string
#  remote_repository_id           :string
#
# Indexes
#
#  index_projects_on_slug  (slug) UNIQUE
#
require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "#collaborator?" do
    project = projects(:one)

    github_collaborators = [
      { login: "user1", permissions: { "push" => true } },
      { login: "user2", permissions: { "push" => false } }
    ]

    project.metadata.update!(github_collaborators: github_collaborators)

    user1 = create(:user, metadata: MetadataUser.new(github_user: { "login" => "user1" }))
    user2 = create(:user, metadata: MetadataUser.new(github_user: { "login" => "user2" }))
    user3 = create(:user, metadata: MetadataUser.new(github_user: { "login" => "user3" }))

    assert project.collaborator?(user1)
    assert_not project.collaborator?(user2)
    assert_not project.collaborator?(user3)
  end

  test "#default_branch when the name exist but the branch doesn't" do
    project = Project.create(remote_repository_id: "user/repo", default_branch_name: "master")

    assert_not project.default_branch.persisted?
    assert_equal "master", project.default_branch.name
  end

  test "#default_branch! when the name exist but the branch doesn't" do
    project = Project.create(remote_repository_id: "user/repo", default_branch_name: "master")

    assert_difference -> { Branch.count }, 1, "A branch is created" do
      assert project.default_branch!
    end
  end

  test "#default_branch! when the name and the branch exist" do
    project = Project.create(remote_repository_id: "user/repo", default_branch_name: "master")
    branch = project.branches.create(name: "master")

    assert_equal branch, project.default_branch!
  end

  test "#default_branch! with multiple projects" do
    project1 = Project.create(remote_repository_id: "user/repo", default_branch_name: "master")
    project2 = Project.create(remote_repository_id: "user/repo", default_branch_name: "master")

    assert_difference -> { Branch.count }, 1, "A branch is created" do
      assert project1.default_branch!
    end

    assert_difference -> { Branch.count }, 1, "A branch is created" do
      assert project2.default_branch!
    end
  end

  test "#name when the field is empty" do
    project = Project.new(name: "", remote_repository_id: "user/repo")
    assert_equal "user/repo", project.name
  end

  test "#name when the field is not empty" do
    project = Project.new(name: "Project 1", remote_repository_id: "user/repo")
    assert_equal "Project 1", project.name
  end

  test "#default_locale when the field is empty" do
    project = Project.new(default_locale: "")
    assert_equal "en", project.default_locale
  end

  test "#default_locale when the field is not empty" do
    project = Project.new(default_locale: "es")
    assert_equal "es", project.default_locale
  end

  test "#translations_path when the field is empty" do
    project = Project.new(translations_path: "")
    assert_equal "config/locales", project.translations_path
  end

  test "#translations_path when the field is not empty" do
    project = Project.new(translations_path: "locales")
    assert_equal "locales", project.translations_path
  end

  test "#url" do
    project = Project.new(name: "Project 1", remote_repository_id: "user/repo")
    assert_equal "#{Babelfu.config.github_domain}/user/repo", project.url
  end

  test "#enqueue_sync_data!" do
    project = projects(:one)
    assert_enqueued_with(job: SyncProjectJob) do
      project.enqueue_sync_data!
    end

    assert project.sync_in_progress?
  end
end
