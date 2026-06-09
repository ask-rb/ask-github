# Changelog

## [0.1.0] - Unreleased

### Added

- Initial release of `ask-github` — GitHub service context for the ask-rb ecosystem.
- **context.rb** — Metadata constants for AI system prompts: `DESCRIPTION`, `DOCS_URL`, `OPENAPI_URL`, `AUTH_NAME`, `AUTH_HOW`, `GEM_NAME`, `GEM_VERSION`, `GEM_DOCS`, `QUICK_START`
- **client.rb** — `Ask::GitHub.client` returns an authenticated Octokit client via `Ask::Auth.resolve(:github_token)`. Wraps client in `ClientProxy` to convert `Octokit::Unauthorized` to `Ask::Auth::InvalidCredential`.
- **error_guide.rb** — `Ask::GitHub::Errors` with rate limit info, HTTP status code descriptions, and exception guidance map for agents.
- **Dependencies:** `ask-auth ~> 0.1`, `octokit ~> 9.0`
- **Testing:** 26 tests, 69 assertions covering context constants, client auth flow, and error guide lookups.
