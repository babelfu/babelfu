# frozen_string_literal: true

require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @project = projects(:one)
    @project.memberships.delete_all
  end

  test "GET #index as a user" do
    sign_in @user
    get projects_url
    assert_response :success
  end

  test "GET #index as a visitor" do
    get projects_url
    assert_response :success
  end

  test "GET #user as a user" do
    sign_in @user
    get user_projects_url
    assert_response :success
  end

  test "GET #user as a visitor" do
    get user_projects_url
    assert_response :redirect
  end

  test "GET #show of private project" do
    @project.update(public: false)

    get project_url(@project)
    assert_response :redirect
  end

  test "GET #show of a public project" do
    @project.update(public: true)

    get project_url(@project)
    assert_response :success
  end

  test "GET #show of a private project as a non member user" do
    @project.update(public: false)

    sign_in @user
    get project_url(@project)
    assert_response :redirect
  end

  test "GET #show of a private project as a member user" do
    @project.update(public: false)
    @project.users << @user

    sign_in @user
    get project_url(@project)
    assert_response :success
  end

  test "GET #new" do
    get new_project_url
    assert_redirected_to new_user_session_url
  end

  test "GET #new as a user" do
    sign_in @user
    get new_project_url
    assert_response :success
  end

  test "POST #create as a visitor" do
    post projects_url, params: { project: { remote_repository_id: "abc:123" } }
    assert_redirected_to new_user_session_url
  end

  test "POST #create as signed user" do
    sign_in @user

    assert_difference("Project.count") do
      post projects_url, params: { project: { remote_repository_id: "abc:123" } }
    end

    project = Project.last
    project.installation_id = "abc"
    project.remote_repository_id = "123"

    assert_redirected_to project_url(project)
  end
end
