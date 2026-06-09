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
