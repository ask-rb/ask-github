---
name: github.use_github
description: How to navigate the GitHub API with Octokit — discover endpoints, handle auth, pagination, and errors
---

Use this skill when you need to interact with GitHub — reading issues, pull
requests, repository contents, search, or managing projects using code tools.

## Step 1: Get the Client

```ruby
client = Ask::GitHub.client
```

This returns an authenticated Octokit client. It expects a valid GitHub personal
access token resolved via `Ask::Auth.resolve(:github_token)`.

If you get an auth error, read `Ask::GitHub::Context::AUTH_HOW` for token setup.

## Step 2: Explore the Context

The gem ships with structured context you should reference:

```ruby
Ask::GitHub::Context::DOCS_URL    # GitHub REST API docs
Ask::GitHub::Context::GEM_DOCS    # Octokit Ruby docs
Ask::GitHub::Context::QUICK_START # Copy-paste examples
Ask::GitHub::Context::GEM_NAME    # "octokit"
```

The `QUICK_START` constant has basic usage examples for common operations
(issues, pull requests, contents, search).

## Step 3: Discover Available Methods

Rather than assuming which methods exist, use code tools to explore the client:

```ruby
# List all public methods (filter out Object basics)
Code.new.call(code: "
  client = Ask::GitHub.client
  puts (client.methods - Object.methods).sort.join(\"\\n\")
")
```

Octokit methods follow REST API patterns:
- `client.issues("owner/repo")` — list issues
- `client.pull_requests("owner/repo")` — list PRs
- `client.contents("owner/repo", path: "README.md")` — read file
- `client.search_issues("query")` — search across repos
- `client.create_issue("owner/repo", "Title", "body")` — create issue

For method specifics, read the Octokit source:
```ruby
Grep.new.call(pattern: "def issues", path: "$GEM_PATH/octokit-*/lib")
```

## Step 4: Authentication Errors

Auth failures are converted to `Ask::Auth::InvalidCredential`. For detailed
error guidance, use:

```ruby
Ask::GitHub::Errors.for("Octokit::NotFound")
Ask::GitHub::Errors.status_code_description(404)
Ask::GitHub::Errors::RATE_LIMIT
```

Common scenarios:
- **401/403**: Token invalid or missing scopes → check token at GitHub settings
- **404**: Resource doesn't exist or is private → verify owner/repo and access
- **429**: Rate limited → wait and retry (5,000 req/hr with token)

## Step 5: Pagination

Octokit auto-paginates by default (`auto_paginate: true`, `per_page: 100`).
For very large result sets, you can iterate manually using the response's
`rels` (relations) links.

## Step 6: Fallback Strategy

If Octokit doesn't have a convenience method for what you need:
1. Check `Ask::GitHub::Context::DOCS_URL` for the REST API endpoint
2. Use `client.get("/endpoint")` for custom REST requests
3. Use the GraphQL API via `client.post("/graphql", { query: "..." })` for complex queries
4. For search, use `client.search_issues("...")` which supports GitHub's query syntax
