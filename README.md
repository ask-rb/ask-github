# ask-github

GitHub service context for AI agents in the ask-rb ecosystem.

Provides an authenticated Octokit client, metadata constants for system prompts, and a structured error guide for common GitHub API issues.

```ruby
gem "ask-github"
```

## Quick Start

### Get an authenticated client

```ruby
require "ask-github"

client = Ask::GitHub.client
client.issues("owner/repo")
client.create_issue("owner/repo", "Title", "Body")
client.pull_requests("owner/repo")
client.contents("owner/repo", path: "Gemfile")
client.search_issues("query")
```

The client is an `Octokit::Client` wrapped in a proxy that converts `Octokit::Unauthorized` into `Ask::Auth::InvalidCredential` with actionable error messages.

### Authentication

The client resolves a GitHub token via `Ask::Auth.resolve(:github_token)`. Tokens can be provided through any configured auth provider:

1. **Environment variable:** `GITHUB_TOKEN`
2. **Credentials file:** `~/.ask/credentials.yml`
3. **Rails credentials:** `Rails.application.credentials.github_token`
4. **OAuth / Database:** Custom providers

Generate a token at [github.com/settings/tokens](https://github.com/settings/tokens) with the `repo` and `read:org` scopes.

## Context Constants

Use these constants to build system prompts for AI agents:

| Constant | Value |
|---|---|
| `Ask::GitHub::DESCRIPTION` | "GitHub — code hosting, issues, pull requests, actions, packages" |
| `Ask::GitHub::DOCS_URL` | https://docs.github.com/en/rest |
| `Ask::GitHub::OPENAPI_URL` | https://api.github.com/openapi.json |
| `Ask::GitHub::AUTH_NAME` | `:github_token` |
| `Ask::GitHub::GEM_NAME` | `"octokit"` |
| `Ask::GitHub::GEM_VERSION` | `"~> 9.0"` |
| `Ask::GitHub::QUICK_START` | Copy-paste Ruby code snippet |

## Error Guide

`Ask::GitHub::Errors` provides structured knowledge for agents:

```ruby
Ask::GitHub::Errors.for("Octokit::NotFound")
# => { message: "...", action: "..." }

Ask::GitHub::Errors.status_code_description(404)
# => "Not Found — Resource does not exist or is private."

Ask::GitHub::Errors::RATE_LIMIT[:authenticated]
# => "5,000 requests per hour"
```

## Development

```
bundle install
bundle exec rake test
```

## License

MIT
