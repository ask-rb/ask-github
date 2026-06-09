# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ask-github"
require "minitest/autorun"
require "mocha/minitest"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path("cassettes", __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data("<GITHUB_TOKEN>") { ENV.fetch("GITHUB_TOKEN", "ghp_dummy_token") }
  config.default_cassette_options = { record: :once, match_requests_on: [:method, :uri, :body] }
end
