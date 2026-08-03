# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_returns_octokit_client_when_token_available
    token = "ghp_test_token_12345"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name.to_s == "github_token" }]
    end

    client = Ask::GitHub.client
    assert_kind_of Octokit::Client, client
    assert_equal token, client.access_token
  end

  def test_client_configures_auto_paginate
    token = "ghp_test_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name.to_s == "github_token" }]
    end

    client = Ask::GitHub.client
    assert client.auto_paginate
    assert_equal 100, client.per_page
  end

  def test_client_raises_missing_credential_without_token
    Ask::Auth.configure do |config|
      config.providers = []
    end

    assert_raises(Ask::Auth::MissingCredential) { Ask::GitHub.client }
  end

  def test_client_raises_invalid_credential_on_401
    token = "bad_token"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { token if name.to_s == "github_token" }]
    end

    Octokit::Client.any_instance.stubs(:get).raises(Octokit::Unauthorized)

    assert_raises(Ask::Auth::InvalidCredential) { Ask::GitHub.client.get("/user") }
  end

  def test_client_rate_limit_info_in_error
    Ask::Auth.configure do |config|
      config.providers = []
    end

    error = assert_raises(Ask::Auth::MissingCredential) { Ask::GitHub.client }
    assert_match(/GITHUB_TOKEN/, error.message)
    assert_match(/github_token/, error.message)
  end
end
