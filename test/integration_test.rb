# frozen_string_literal: true

require_relative "test_helper"

class IntegrationTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_can_connect_to_github
    skip("Set GITHUB_TOKEN to run integration tests") unless ENV["GITHUB_TOKEN"]

    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { ENV["GITHUB_TOKEN"] if name == "github_token" }]
    end

    VCR.use_cassette("github_root") do
      client = Ask::GitHub.client
      root = client.get("/")
      assert root.key?(:current_user_url)
    end
  end

  def test_client_can_list_repos_for_authenticated_user
    skip("Set GITHUB_TOKEN to run integration tests") unless ENV["GITHUB_TOKEN"]

    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { ENV["GITHUB_TOKEN"] if name == "github_token" }]
    end

    VCR.use_cassette("github_user_repos") do
      client = Ask::GitHub.client
      repos = client.repos
      assert_kind_of Array, repos
    end
  end

  def test_client_raises_invalid_credential_with_bad_token
    skip("Set GITHUB_TOKEN to run integration tests") unless ENV["GITHUB_TOKEN"]

    # Use actual bad token for an auth-failure VCR cassette
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { "ghp_invalid_token_for_testing" }]
    end

    VCR.use_cassette("github_bad_token") do
      client = Ask::GitHub.client
      assert_raises(Ask::Auth::InvalidCredential) { client.get("/user") }
    end
  end
end
