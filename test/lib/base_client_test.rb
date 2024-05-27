# frozen_string_literal: true

require "test_helper"

class BaseClientTest < ActiveSupport::TestCase
  class DummyClient < BaseClient
    api_wrapper def _dummy_method
      "dummy"
    end

    api_wrapper def _dummy_method2
      "dummy 2"
    end

    def valid_access_token?
      true
    end

    def access_token
      "dummy token"
    end

    def fetch_and_save_access_token!
      true
    end

    def fetch_access_token_mutex_key
      "dummy-mutex-key"
    end
  end

  test "defines a method without the _ and return the value" do
    client = DummyClient.new
    client.stubs(:client).returns(Struct.new(:last_response).new(Struct.new(:status).new(200)))
    assert_equal "dummy", client.dummy_method
  end

  test "raises an error if the response status is not 200 or 201" do
    client = DummyClient.new

    client.stubs(:client).returns(Struct.new(:last_response).new(Struct.new(:status).new(500)))
    assert_raises(BaseClient::RequestError) { client.dummy_method }
  end

  test "retries the request if the response is Unauthorized" do
    client = DummyClient.new
    client.stubs(:client).returns(Struct.new(:last_response).new(Struct.new(:status).new(200)))
    client.stubs(:_dummy_method).raises(Octokit::Unauthorized).then.returns("dummy")

    assert_equal "dummy", client.dummy_method
  end

  test "retries the request only once" do
    client = DummyClient.new
    client.stubs(:client).returns(Struct.new(:last_response).new(Struct.new(:status).new(200)))

    client.stubs(:_dummy_method).raises(Octokit::Unauthorized).then.raises(Octokit::Unauthorized)
    assert_raises(Octokit::Unauthorized) { client.dummy_method }

    client.stubs(:_dummy_method2).raises(Octokit::Unauthorized).then.returns("dummy 2")
    assert_equal "dummy 2", client.dummy_method2
  end

  test "#client returns @client" do
    client = DummyClient.new
    stub_client = stub(:client)
    client.instance_variable_set(:@client, stub_client)
    assert_equal stub_client, client.client
  end

  test "#client builds_client if @client is nil" do
    client = DummyClient.new
    client.instance_variable_set(:@client, nil)

    stub_client = stub(:client)
    client.expects(:build_client).returns(stub_client)
    client.client
  end

  test "#build_client builds a new Octokit::Client" do
    client = DummyClient.new
    client.expects(:fetch_access_token!).with(force: false).returns("dummy token")
    client.build_client
    assert_instance_of Octokit::Client, client.client
  end

  test "#build_client calls fetch_access_token! with force true" do
    client = DummyClient.new
    client.expects(:fetch_access_token!).with(force: true).returns("dummy token")
    client.build_client(force: true)
    assert_instance_of Octokit::Client, client.client
  end
end
