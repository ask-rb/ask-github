# frozen_string_literal: true

require_relative "test_helper"

class IntegrationTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_can_fetch_root
    VCR.use_cassette("github_root") do
      Ask::Auth.configure do |config|
        config.providers = [->(name, user: nil) { ENV.fetch("GITHUB_TOKEN", "ghp_dummy") if name == "github_token" }]
      end

      client = Ask::GitHub.client
      root = client.get("/")
      assert root.key?(:current_user_url)
    end
  end

  def test_client_raises_missing_credential
    Ask::Auth.configure { |c| c.providers = [] }

    assert_raises(Ask::Auth::MissingCredential) { Ask::GitHub.client }
  end

  def test_client_raises_invalid_credential_on_401
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { "ghp_bad_token" if name == "github_token" }]
    end

    Octokit::Client.any_instance.stubs(:get).raises(Octokit::Unauthorized)

    assert_raises(Ask::Auth::InvalidCredential) { Ask::GitHub.client.get("/user") }
  end

  def test_client_can_list_repos
    VCR.use_cassette("github_user_repos") do
      Ask::Auth.configure do |config|
        config.providers = [->(name, user: nil) { ENV.fetch("GITHUB_TOKEN", "ghp_dummy") if name == "github_token" }]
      end

      client = Ask::GitHub.client
      repos = client.repos
      assert_kind_of Array, repos
    end
  end

  def test_delegates_to_octokit
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { "ghp_test" if name == "github_token" }]
    end

    client = Ask::GitHub.client
    assert client.respond_to?(:repos)
    assert client.respond_to?(:issues)
    assert client.respond_to?(:pull_requests)
    assert client.respond_to?(:get)
    refute client.respond_to?(:nonexistent_method_xyz)
  end
end
