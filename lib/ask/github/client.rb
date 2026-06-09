# frozen_string_literal: true

require "octokit"
require "ask/auth"

module Ask
  module GitHub
    # Returns an authenticated Octokit client configured for an AI agent.
    #
    # Resolves the GitHub token via +Ask::Auth.resolve(:github_token)+ and
    # wraps the client in a proxy that converts +Octokit::Unauthorized+ into
    # +Ask::Auth::InvalidCredential+.
    #
    # Configuration:
    # - +auto_paginate+: +true+ (collects all pages automatically)
    # - +per_page+: +100+ (maximum items per page)
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

      ClientProxy.new(Octokit::Client.new(access_token: token, auto_paginate: true, per_page: 100))
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
