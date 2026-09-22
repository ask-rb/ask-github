# ask-github

[![Gem Version](https://badge.fury.io/rb/ask-github.svg)](https://badge.fury.io/rb/ask-github)

> **⚠️ DEPRECATED**
>
> This gem is **deprecated**. Use GitHub's official MCP server instead.
>
> Existing gem installations may continue to work, but this repository will receive no further feature development.

GitHub service context for AI agents in the ask-rb ecosystem. It provides an
authenticated Octokit client for the GitHub REST API, metadata constants for
system prompts, and a structured error guide for common GitHub API issues.

## Installation

```ruby
gem "ask-github"
```

## Quick Start

```ruby
require "ask-github"

client = Ask::GitHub.client
client.issues("owner/repo")
client.create_issue("owner/repo", "Title", "Body")
client.pull_requests("owner/repo")
client.contents("owner/repo", path: "Gemfile")
client.search_issues("query")
```

## Authentication

`Ask::GitHub.client` resolves a token via `Ask::Auth.resolve(:github_token)`.
Set it in your environment:

```bash
export GITHUB_TOKEN=your_token_here
```

Or add it to `~/.ask/credentials.yml`:

```yaml
github_token: your_token_here
```

Credentials can also come from Rails credentials, a database, or an OAuth
provider, depending on your `ask-auth` configuration. Generate a token at
[github.com/settings/tokens](https://github.com/settings/tokens) with the
`repo` and `read:org` scopes.

## Key entry points

- `Ask::GitHub.client` - an authenticated `Octokit::Client` (auto-paginating,
  `per_page: 100`, retry middleware). It is wrapped in a proxy that converts
  `Octokit::Unauthorized` into `Ask::Auth::InvalidCredential`.
- `Ask::GitHub::Errors` - structured error knowledge for agents: guidance by
  exception class, HTTP status code descriptions, and rate limit info.
- `Ask::GitHub::DESCRIPTION`, `DOCS_URL`, `AUTH_NAME`, `GEM_NAME`,
  `GEM_VERSION`, and `QUICK_START` - metadata constants for system prompts.

## Full documentation

The full ask-rb documentation lives at https://ask-rb.github.io/ask-docs.
[Services: GitHub](https://ask-rb.github.io/ask-docs/services/github) covers
ask-github in depth, including the client, error guide, and constants.
API reference: https://ask-rb.github.io/ask-docs/reference/api.

## Development

```
bundle install
bundle exec rake test
```

## License

MIT
