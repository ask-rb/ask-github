# frozen_string_literal: true

require_relative "test_helper"

class ContextTest < Minitest::Test
  def test_description_is_defined
    assert_match(/GitHub/, Ask::GitHub::DESCRIPTION)
  end

  def test_docs_url_is_defined
    assert Ask::GitHub::DOCS_URL.start_with?("https://docs.github.com")
  end

  def test_openapi_url_is_defined
    assert Ask::GitHub::OPENAPI_URL.start_with?("https://api.github.com")
  end

  def test_auth_name_is_github_token
    assert_equal :github_token, Ask::GitHub::AUTH_NAME
  end

  def test_auth_how_is_defined
    assert_includes Ask::GitHub::AUTH_HOW, "settings/tokens"
  end

  def test_gem_name_is_octokit
    assert_equal "octokit", Ask::GitHub::GEM_NAME
  end

  def test_gem_version_is_defined
    assert_match(/~> 9\.0/, Ask::GitHub::GEM_VERSION)
  end

  def test_gem_docs_is_defined
    assert Ask::GitHub::GEM_DOCS.start_with?("https://octokit.github.io")
  end

  def test_quick_start_is_defined
    assert_includes Ask::GitHub::QUICK_START, "Ask::GitHub.client"
  end

  def test_quick_start_includes_common_methods
    %w[issues create_issue pull_requests contents search_issues].each do |method|
      assert_includes Ask::GitHub::QUICK_START, method
    end
  end
end
