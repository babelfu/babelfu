# frozen_string_literal: true

require "test_helper"

class UserClientTest < ActiveSupport::TestCase
  test "#valid_access_token? returns true if access token is valid" do
    user = users(:one)
    user.github_access_token = "access token"
    user.github_access_token_expires_at = 1.hour.from_now
    client = UserClient.new(user)

    assert client.valid_access_token?
  end

  test "#fetch_and_save_access_token! generates and saves access token" do
    user = users(:one)
    user.github_refresh_token = "refresh_token"

    token_data = { "access_token" => "access token", "expires_in" => 360, "refresh_token" => "refresh token", "refresh_token_expires_in" => 3600 }
    GithubAppClient.expects(:generate_access_token_from_refresh_token).with("refresh_token").returns(token_data)

    client = UserClient.new(user)
    client.fetch_and_save_access_token!

    assert_equal "access token", user.github_access_token
    assert_equal "refresh token", user.github_refresh_token
    assert user.github_access_token_expires_at > Time.current
    assert user.github_refresh_token_expires_at > Time.current
  end

  test "#fetch_access_token_mutex_key" do
    user = users(:one)
    client = UserClient.new(user)

    assert_equal "user:#{user.id}:fetch_access_token", client.fetch_access_token_mutex_key
  end

  test "#access_token" do
    user = users(:one)
    user.github_access_token = "access token"
    client = UserClient.new(user)

    assert_equal "access token", client.access_token
  end

  test "#find_installation_repositories_for_user" do
    user = users(:one)
    user_client = UserClient.new(user)
    user_client.client.expects(:find_installation_repositories_for_user).with(1).returns("repositories")
    user_client.client.stubs(last_response: Struct.new(:status).new(200))

    assert_equal "repositories", user_client.find_installation_repositories_for_user(1)
  end

  test "#find_user_installations" do
    user = users(:one)
    user_client = UserClient.new(user)
    user_client.client.expects(:find_user_installations).returns("installations")
    user_client.client.stubs(last_response: Struct.new(:status).new(200))

    assert_equal "installations", user_client.find_user_installations
  end

  test "#github_user" do
    user = users(:one)
    user_client = UserClient.new(user)
    user_client.client.expects(:user).returns("user")
    user_client.client.stubs(last_response: Struct.new(:status).new(200))

    assert_equal "user", user_client.github_user
  end
end
