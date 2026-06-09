# frozen_string_literal: true

require "octokit"
require "ask/auth"

module Ask
  module GitHub
    # Returns an authenticated Octokit client configured for an AI agent.
    #
    # Resolves the GitHub token via +Ask::Auth.resolve(:github_token)+ and
    # configures the client with sensible defaults:
    #
    # - +auto_paginate+: +true+ (collects all pages automatically)
    # - +per_page+: +100+ (maximum items per page)
    # - +middleware+: Faraday retry middleware (3 retries, exponential backoff)
    #
    # The client is wrapped in a +ClientProxy+ that converts
    # +Octokit::Unauthorized+ into +Ask::Auth::InvalidCredential+.
    #
    # @example
    #   client = Ask::GitHub.client
    #   client.issues("owner/repo")
    #
    # @return [Octokit::Client] an authenticated client
    # @raise [Ask::Auth::MissingCredential] if no GitHub token is configured
    # @raise [Ask::Auth::InvalidCredential] if the token is rejected (401)
    def self.client
      token = Ask::Auth.resolve(:github_token)

      client = Octokit::Client.new(access_token: token, auto_paginate: true, per_page: 100)

      # Configure Faraday retry middleware for transient failures
      client.middleware = Faraday::RackBuilder.new do |builder|
        builder.request :retry, max: 3, interval: 1, backoff_factor: 2,
                                retry_statuses: [429, 500, 502, 503]
        builder.adapter Faraday.default_adapter
      end

      ClientProxy.new(client)
    end

    # Proxies method calls to an +Octokit::Client+, converting authentication
    # errors into +Ask::Auth::InvalidCredential+.
    class ClientProxy < BasicObject
      def initialize(client)
        @client = client
      end

      def method_missing(name, ...)
        @client.public_send(name, ...)
      rescue ::Octokit::Unauthorized
        ::Kernel.raise ::Ask::Auth::InvalidCredential, :github_token
      end

      def respond_to_missing?(name, include_private = false)
        @client.respond_to?(name, include_private) || super
      end
    end
  end
end
