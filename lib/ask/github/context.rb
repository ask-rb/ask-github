# frozen_string_literal: true

module Ask
  module GitHub
    # Human-readable description of the GitHub service context.
    DESCRIPTION = "GitHub — code hosting, issues, pull requests, actions, packages"

    # Base URL for GitHub REST API documentation.
    DOCS_URL = "https://docs.github.com/en/rest"

    # URL for the GitHub OpenAPI specification.
    OPENAPI_URL = "https://api.github.com/openapi.json"

    # Credential name used with Ask::Auth.resolve.
    AUTH_NAME = :github_token

    # Instructions for obtaining a GitHub personal access token.
    AUTH_HOW = "https://github.com/settings/tokens — scopes: repo, read:org"

    # Gem name for the GitHub API client.
    GEM_NAME = "octokit"

    # Required gem version constraint.
    GEM_VERSION = "~> 9.0"

    # URL for Octokit Ruby library documentation.
    GEM_DOCS = "https://octokit.github.io/octokit.rb"

    # Quick-start Ruby code snippet for agents to copy-paste.
    QUICK_START = <<~RUBY
      client = Ask::GitHub.client
      client.issues("owner/repo")
      client.create_issue("owner/repo", "Title", "Body")
      client.pull_requests("owner/repo")
      client.contents("owner/repo", path: "Gemfile")
      client.search_issues("query")
    RUBY
  end
end
