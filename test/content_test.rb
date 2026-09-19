# frozen_string_literal: true

require_relative "test_helper"

class ContentTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
    @octokit = Object.new
    @content = Ask::GitHub::Content.new(@octokit)
  end

  def test_default_branch_reads_the_repo
    repo = Struct.new(:default_branch).new("main")
    @octokit.define_singleton_method(:repo) { |_repo| repo }

    assert_equal "main", @content.default_branch("owner/repo")
  end

  def test_tree_lists_recursive_entries_as_path_and_type
    tree = Struct.new(:tree).new([
      Struct.new(:path, :type).new("README.md", "blob"),
      Struct.new(:path, :type).new("docs/guide.md", "blob"),
      Struct.new(:path, :type).new("docs", "tree")
    ])
    @octokit.define_singleton_method(:tree) { |_repo, _sha, **_opts| tree }
    @octokit.define_singleton_method(:repo) { |_repo| Struct.new(:default_branch).new("main") }

    entries = @content.tree("owner/repo")

    assert_equal(
      [["README.md", "blob"], ["docs/guide.md", "blob"], ["docs", "tree"]],
      entries.map { |e| [e[:path], e[:type]] }
    )
  end

  def test_file_reads_raw_content_at_a_path_on_the_default_branch
    @octokit.define_singleton_method(:contents) do |_repo, path:, ref:, accept:|
      "#{path}@#{ref} raw content"
    end
    @octokit.define_singleton_method(:repo) { |_repo| Struct.new(:default_branch).new("main") }

    assert_equal "docs/guide.md@main raw content", @content.file("owner/repo", "docs/guide.md")
  end

  def test_file_returns_nil_when_the_path_does_not_exist
    @octokit.define_singleton_method(:contents) { |*| raise Octokit::NotFound }
    @octokit.define_singleton_method(:repo) { |_repo| Struct.new(:default_branch).new("main") }

    assert_nil @content.file("owner/repo", "missing.md")
  end

  def test_license_reads_the_spdx_id
    license = Struct.new(:license).new(Struct.new(:spdx_id).new("mit"))
    @octokit.define_singleton_method(:license) { |_repo| license }

    assert_equal "mit", @content.license("owner/repo")
  end

  def test_license_returns_nil_when_the_repo_is_unlicensed
    @octokit.define_singleton_method(:license) { |*| raise Octokit::NotFound }

    assert_nil @content.license("owner/repo")
  end

  def test_unauthorized_maps_to_invalid_credential
    @octokit.define_singleton_method(:repo) { |*| raise Octokit::Unauthorized }

    assert_raises(Ask::Auth::InvalidCredential) { @content.default_branch("owner/repo") }
  end
end

class ClientTokenTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_accepts_an_explicit_token_without_the_auth_chain
    client = Ask::GitHub.client(token: "ghp_explicit")

    assert_kind_of Octokit::Client, client
    assert_equal "ghp_explicit", client.access_token
  end

  def test_client_still_resolves_through_the_auth_chain_without_a_token
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { "ghp_resolved" if name.to_s == "github_token" }]
    end

    client = Ask::GitHub.client

    assert_equal "ghp_resolved", client.access_token
  end

  def test_proxy_exposes_the_content_helpers
    client = Ask::GitHub.client(token: "ghp_explicit")

    assert_respond_to client, :default_branch
    assert_respond_to client, :tree
    assert_respond_to client, :file
    assert_respond_to client, :license
  end
end
