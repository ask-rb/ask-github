# ask-github

github service context for the ask-rb ecosystem.

Provides:
- `Ask::github.client` — authenticated API client
- `Ask::github.context` — context metadata for the system prompt
- `Ask::github::Errors` — structured error knowledge for agents

## Installation

```ruby
gem "ask-github"
```

## Usage

```ruby
client = Ask::github.client
# ... use the client according to its API
```

## Development

```bash
bin/setup
bundle exec rake test
```

## License

MIT
