# ask-github — GitHub Service Context

## Purpose

Service context gem for GitHub. Provides three files:
- `context.rb` — metadata for the system prompt (API docs, auth instructions, quick-start code snippets)
- `client.rb` — authenticated Octokit client helper
- `error_guide.rb` — structured error knowledge for agents

No tool classes. The agent reads the context from the system prompt, writes Ruby code using the `client` helper, and executes it with the `Code` tool from `ask-tools-shell`.

## Dependencies

- **Runtime:**
  - `ask-auth` (for `Ask::Auth.resolve(:github_token)`)
  - `octokit ~> 9.0` (GitHub's official Ruby client)
- **Build/test:** minitest, mocha, rake, vcr, webmock
- **This gem MUST wait until `ask-auth` is built, tested, and released.** The client helper depends on `Ask::Auth.resolve`.

## Implementation Steps

### 1. Define the gem scaffold
- `lib/ask-github.rb` — entry point, requires `ask/auth` and `octokit`
- `lib/ask/github.rb` — module that ties everything together
- `lib/ask/github/version.rb`
- `lib/ask/github/context.rb` — metadata constants
- `lib/ask/github/client.rb` — `Ask::GitHub.client` helper
- `lib/ask/github/error_guide.rb` — `Ask::GitHub::Errors` module
- `ask-github.gemspec` — depends on `ask-auth`, `octokit`

### 2. Build context.rb
```ruby
module Ask::GitHub
  DESCRIPTION  = "GitHub — code hosting, issues, pull requests, actions, packages"
  DOCS_URL     = "https://docs.github.com/en/rest"
  OPENAPI_URL  = "https://api.github.com/openapi.json"
  AUTH_NAME    = :github_token
  AUTH_HOW     = "https://github.com/settings/tokens — scopes: repo, read:org"
  GEM_NAME     = "octokit"
  GEM_VERSION  = "~> 9.0"
  GEM_DOCS     = "https://octokit.github.io/octokit.rb"
  QUICK_START  = <<~RUBY
    client = Ask::GitHub.client
    client.issues("owner/repo")
    client.create_issue("owner/repo", "Title", "Body")
    client.pull_requests("owner/repo")
    client.contents("owner/repo", path: "Gemfile")
    client.search_issues("query")
  RUBY
end
```

### 3. Build client.rb
- `Ask::GitHub.client` returns an authenticated Octokit client
- Resolves token via `Ask::Auth.resolve(:github_token)`
- Raises `Ask::Auth::MissingCredential` with instructions if no token found
- Configures: `auto_paginate: true`, `per_page: 100`
- Catches `Octokit::Unauthorized` and raises `Ask::Auth::InvalidCredential`

### 4. Build error_guide.rb
- Map of common error patterns and what the agent should do
- Rate limit info (auth: 5K/hr, anon: 60/hr)
- Pagination info (Link header, auto_paginate)
- Common HTTP status codes and their meanings for GitHub

### 5. Test coverage
- Test context constants are accessible and correct
- Test client returns an authenticated `Octokit::Client`
- Test client raises `Ask::Auth::MissingCredential` when no token configured
- Test client raises `Ask::Auth::InvalidCredential` on 401 (mock Octokit)
- Test error guide maps are accurate

### 6. README
- Quick start: `Ask::GitHub.client` and writing agent code
- Auth setup instructions
- Common usage patterns
- How to develop and test locally

## What "Done" Means

- `Ask::GitHub.client` returns authenticated Octokit client
- `Ask::GitHub::DESCRIPTION` and other constants are accessible
- Error guide provides actionable info for all common GitHub API errors
- Tests pass with mocked credentials and API responses
- An agent with `ask-github` installed automatically gets GitHub context in its system prompt (via `ask-rails` service discovery)

## Documentation

### Documentation
- **Update ask-docs** after releasing v0.1.0 — the docs site at github.com/ask-rb/ask-docs must reflect this gems API, usage, and position in the ecosystem.
- The ask-docs repo has a Jekyll site with sections for each gem under core/, providers/, tools/, agent/.
- Add or update the relevant page(s) and submit a PR to ask-docs.
- This is not optional — ask-docs is the public face of the ecosystem.

## Release Checklist (Required for v0.1.0)

Before declaring this gem done and releasing v0.1.0, verify:

- [] All tests pass with >90% coverage
- [] Every public API method has documentation (yardoc or inline comments)
- [] README is complete: installation, quick start, configuration, development
- [] CHANGELOG.md exists with an entry for v0.1.0
- [] All code is committed and pushed to github.com/ask-rb/ask-github
- [] Gem builds without errors: gem build *.gemspec
- [] Gem is released as a private gem (see guides/RELEASING.md when available)
- [] A consumer app can install, require, and use the gem with no errors
- [] Thread-safety verified (registry, config, client construction)
- [] Error messages are helpful and actionable

## What Done Means for v0.1.0

The gem reaches v0.1.0 when:
- All implementation steps above are complete and tested
- The gem is released on GitHub Packages as a private gem
- A real consumer can install it with gem install or Bundler
- A consumer script can require it and use its full public API
- The README provides enough information for someone unfamiliar to get started in 5 minutes
- The CHANGELOG documents what v0.1.0 delivers

## Development Workflow

### Git conventions
- Follow the git-workflow skill for branch naming, commit messages, and PR structure.
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- One logical change per commit. No "fixup" or "wip" commits on main.
- Commit messages must be one direct sentence describing the change.

### Reference projects
Study existing implementations for patterns and conventions:

- **ask-tools-shell** — extract from `ruby_llm-conductor/lib/ruby_llm/conductor/tools/`
- **ask-agent** — port from `ruby_llm-conductor/` (session, loop, tool_executor, compactor, etc.)
- **ask-rails** — transform from `solid_agents/` (railtie, generators, persistence)
- **ask-openai, ask-anthropic** — study `ruby_llm/lib/ruby_llm/providers/` for wire formats and streaming patterns
- **ask-openai** — also study `llm-proxy/lib/llm_proxy/protocols/` for OpenAI protocol conversion
- **General patterns** — study `pi/packages/ai/src/providers/` for lazy loading, registration, and protocol families
- **Test patterns** — study `ruby_llm/spec/` for VCR cassette structure and integration testing patterns
- **ask-github** — reference implementation for service context gems; follow its three-file pattern

### Testing
- Use Minitest (not RSpec) — consistent with the ask-rb ecosystem.
- Unit tests for every public method (normal path + edge cases + error cases).
- Integration tests with VCR cassettes for any gem that calls external APIs.
- Run the full suite before every commit: `bundle exec rake test`.
