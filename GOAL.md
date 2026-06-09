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


## Documentation

### Documentation
- **Update ask-docs** after releasing v0.1.0 — the docs site at github.com/ask-rb/ask-docs must reflect this gems API, usage, and position in the ecosystem.
- The ask-docs repo has a Jekyll site with sections for each gem under core/, providers/, tools/, agent/.
- Add or update the relevant page(s) and submit a PR to ask-docs.
- This is not optional — ask-docs is the public face of the ecosystem.

## Improving Parent Gems During Development

### Improving Parent Gems During Development

If during development you discover something in a parent gem (a dependency of this gem)
that needs to be fixed or improved:

1. Make the change in the parent gem's repository at `/Users/kaka/Code/ask-rb/GEMNAME/`
2. Ensure existing tests in the parent gem still pass: `cd ../PARENT && bundle exec rake test`
3. Ensure tests in THIS gem still pass: `bundle exec rake test`
4. Ensure the parent gem still builds: `gem build *.gemspec`
5. Commit the parent gem change, bump its patch version, and push:
   `cd ../PARENT && git commit -m "fix: ..." && git push`
6. Update this gem's Gemfile to reference the updated parent gem
7. Continue with this gem's implementation using the fixed parent

Do NOT break parent functionality. Do NOT change parent APIs without testing
both gems. Parent gems have their own consumers — treat them with care.


## What Done Means for v0.1.0

The gem reaches v0.1.0 when:
- All implementation steps above are complete and tested
- The gem is released on RubyGems
- A real consumer can install it with gem install or Bundler
- A consumer script can require it and use its full public API
- The README provides enough information for someone unfamiliar to get started in 5 minutes
- The CHANGELOG documents what v0.1.0 delivers


## v0.1.0 Completion Checklist

A gem is NOT done until every item in this checklist passes. No shortcuts. If you cannot check every box, the gem is NOT finished.

### Code & Tests
- [ ] Every public method has unit tests (happy path + edge cases + error cases)
- [ ] Tests cover: normal operation, missing inputs, invalid inputs, network errors, auth failures
- [ ] Integration tests with real recorded API calls using VCR cassettes (for any gem that calls external APIs)
- [ ] All tests pass: `bundle exec rake test`
- [ ] Test coverage >= 90% (measure with simplecov)
- [ ] Thread-safety verified for any shared state (registries, config, client construction)
- [ ] No warnings on load
- [ ] No dependency conflicts

### Documentation
- [ ] README is complete: installation, quick start, configuration, examples, development
- [ ] Every public method documented (yardoc or inline comments)
- [ ] CHANGELOG.md exists with v0.1.0 entry

### Release
- [ ] Gem builds without errors: `gem build *.gemspec`
- [ ] Gem is released on RubyGems.org: `gem push *.gem`
- [ ] A fresh install works: `gem install GEMNAME` in a clean directory
- [ ] A consumer script can require and use the full public API

### Production Hardening
- [ ] Error messages are helpful and actionable (tell the user what went wrong AND what to do)
- [ ] Network timeouts handled (Timeout::Error, Errno::ECONNREFUSED, etc.)
- [ ] Retry logic for transient failures (rate limits, 429, 503)
- [ ] Sensible defaults for all configuration options
- [ ] Input validation rejects invalid parameters with clear messages
- [ ] Logging does not leak sensitive data (tokens, keys)

### CI/CD
- [ ] GitHub Actions workflow runs tests on push and PR (`.github/workflows/ci.yml`)
- [ ] CI passes on Ruby 3.2, 3.3, 3.4

### Post-Release
- [ ] ask-docs repository updated with this gem documentation
- [ ] Version tag exists: `git tag v0.1.0 && git push --tags`

### Service-Specific
- [ ] Client has talked to the real GitHub API (tested with a real token)
- [ ] VCR cassette recorded for at least one successful API call
- [ ] Rate limit errors handled (403 with rate limit info)
- [ ] Auth errors return Ask::Auth::InvalidCredential
- [ ] Pagination works (auto_paginate or Link header parsing)

## Development Workflow

### Git conventions
- The default branch is **master**. All work should be based on master unless a specific branch is requested.

- Follow the git-workflow skill for branch naming, commit messages, and PR structure.
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- One logical change per commit. No "fixup" or "wip" commits on master.
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
### Reference Repositories (Local)
All ask-rb gem repos are available locally at /Users/kaka/Code/ask-rb/ for reference.
Do not clone from GitHub — use the local directories:
- Source code: /Users/kaka/Code/ask-rb/GEMNAME/lib/
- Tests: /Users/kaka/Code/ask-rb/GEMNAME/test/
- Goal: /Users/kaka/Code/ask-rb/GEMNAME/GOAL.md
- Gemspec: /Users/kaka/Code/ask-rb/GEMNAME/GEMNAME.gemspec

Other reference projects in the same workspace:
- /Users/kaka/Code/ask-rb/ruby_llm/ — RubyLLM gem (providers, models, streaming)
- /Users/kaka/Code/ask-rb/ruby_llm-conductor/ — Original conductor (agent loop, tools)
- /Users/kaka/Code/ask-rb/llm-proxy/ — Protocol normalization patterns
- /Users/kaka/Code/ask-rb/pi/ — Pi agent (TypeScript, provider architecture)
- /Users/kaka/Code/ask-rb/solid_agents/ — Original solid_agents (Rails engine)
- /Users/kaka/Code/ask-rb/composio/ — Composio SDK (MCP tool execution examples)
- /Users/kaka/Code/ask-rb/ask-docs/ — Documentation site (update after release)

### Testing
- Use Minitest (not RSpec) — consistent with the ask-rb ecosystem.
- Unit tests for every public method (normal path + edge cases + error cases).
- Integration tests with VCR cassettes for any gem that calls external APIs.
- Run the full suite before every commit: `bundle exec rake test`.
