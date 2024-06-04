# frozen_string_literal: true

require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @project = projects(:one)
    @project.users << @user
  end

  test "as member of a project" do
    sign_in @user
    get projects_url
    assert_response :success
  end

  test "as a visitor" do
    get projects_url
    assert_response :success
  end
end
