## Deprecated - 2026-09-22

The `ask-github` gem is deprecated. Existing installations may continue to work, but this repository will receive no further feature development. Use GitHub's official GitHub MCP Server instead: https://github.com/github/github-mcp-server

## [0.1.3] - 2026-06-25

### Changed
- Gemspec validation test. Infrastructure: rubocop, overcommit, bin/setup, CI matrix. VCR rake tasks for cassette freshness.
# Changelog

## [0.2.0] - 2026-08-16

### Added

- **client.rb** — `Ask::GitHub.client(token: nil)` accepts an explicit token (the connector path; token resolution still falls back to `Ask::Auth.resolve(:github_token)`).
- **Content helpers** — `default_branch(repo)`, `tree(repo, branch:)`, `file(repo, path, branch:)`, and `license(repo)` for docs-as-code sources; 401s map to `Ask::Auth::InvalidCredential` like every other call.


## [0.1.2] - 2026-06-21

### Added

- Initial release of `ask-github` — GitHub service context for the ask-rb ecosystem.
- **context.rb** — Metadata constants for AI system prompts: `DESCRIPTION`, `DOCS_URL`, `OPENAPI_URL`, `AUTH_NAME`, `AUTH_HOW`, `GEM_NAME`, `GEM_VERSION`, `GEM_DOCS`, `QUICK_START`
- **client.rb** — `Ask::GitHub.client` returns an authenticated Octokit client via `Ask::Auth.resolve(:github_token)`. Wraps client in `ClientProxy` to convert `Octokit::Unauthorized` to `Ask::Auth::InvalidCredential`.
- **error_guide.rb** — `Ask::GitHub::Errors` with rate limit info, HTTP status code descriptions, and exception guidance map for agents.
- **Dependencies:** `ask-auth ~> 0.1`, `octokit ~> 9.0`
- **Testing:** 26 tests, 69 assertions covering context constants, client auth flow, and error guide lookups.
