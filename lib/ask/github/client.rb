# frozen_string_literal: true

require "octokit"
require "ask/auth"

module Ask
  module GitHub
    # Returns an authenticated Octokit client configured for an AI agent
    # or a content connector.
    #
    # Resolves the GitHub token via +Ask::Auth.resolve(:github_token)+,
    # or uses the +token:+ given explicitly (the connector path — the
    # token comes from the host app's own credential store). Configures
    # the client with sensible defaults:
    #
    # - +auto_paginate+: +true+ (collects all pages automatically)
    # - +per_page+: +100+ (maximum items per page)
    # - +middleware+: Faraday retry middleware (3 retries, exponential backoff)
    #
    # The client is wrapped in a +ClientProxy+ that converts
    # +Octokit::Unauthorized+ into +Ask::Auth::InvalidCredential+, and
    # exposes the repo-content helpers (+default_branch+, +tree+, +file+,
    # +license+) for docs-as-code sources.
    #
    # @example
    #   client = Ask::GitHub.client
    #   client.issues("owner/repo")
    #
    # @example connector with an explicit token
    #   client = Ask::GitHub.client(token: credential.token)
    #   client.default_branch("owner/repo")
    #
    # @return [ClientProxy] an authenticated client
    # @raise [Ask::Auth::MissingCredential] if no GitHub token is configured
    # @raise [Ask::Auth::InvalidCredential] if the token is rejected (401)
    def self.client(token: nil)
      token ||= Ask::Auth.resolve(:github_token)

      client = Octokit::Client.new(access_token: token, auto_paginate: true, per_page: 100)

      # Configure Faraday retry middleware for transient failures
      client.middleware = Faraday::RackBuilder.new do |builder|
        builder.request :retry, max: 3, interval: 1, backoff_factor: 2,
                                retry_statuses: [429, 500, 502, 503]
        builder.adapter Faraday.default_adapter
      end

      ClientProxy.new(client)
    end

    # The repo-content helpers: the raw pieces a docs-as-code connector
    # needs (tree listing, raw file reads, the default branch, and the
    # repo's license). Explicit methods, so connectors never poke at
    # Octokit's full surface.
    class Content
      def initialize(client)
        @client = client
      end

      # The repository's default branch name (e.g. "main").
      def default_branch(repo)
        call { @client.repo(repo).default_branch }
      end

      # The recursive file tree for a branch: [{path:, type:}] entries.
      # GitHub truncates enormous trees; callers bound what they consume.
      def tree(repo, branch: nil)
        sha = branch || default_branch(repo)
        call { @client.tree(repo, sha, recursive: true) }.tree.map do |entry|
          {path: entry.path, type: entry.type}
        end
      end

      # A file's raw content at a path, or nil when the path doesn't exist.
      def file(repo, path, branch: nil)
        call do
          @client.contents(repo, path: path, ref: branch || default_branch(repo),
            accept: "application/vnd.github.raw")
        end
      rescue ::Octokit::NotFound
        nil
      end

      # The repo's SPDX license id (e.g. "mit"), or nil when unlicensed.
      def license(repo)
        call { @client.license(repo) }&.license&.spdx_id
      rescue ::Octokit::NotFound
        nil
      end

      private

      def call
        yield
      rescue ::Octokit::Unauthorized
        ::Kernel.raise ::Ask::Auth::InvalidCredential, :github_token
      end
    end

    # Proxies method calls to an +Octokit::Client+, converting
    # authentication errors into +Ask::Auth::InvalidCredential+, and
    # exposing the content helpers.
    class ClientProxy < BasicObject
      def initialize(client)
        @client = client
        @content = ::Ask::GitHub::Content.new(client)
      end

      def default_branch(repo)
        @content.default_branch(repo)
      end

      def tree(repo, branch: nil)
        @content.tree(repo, branch: branch)
      end

      def file(repo, path, branch: nil)
        @content.file(repo, path, branch: branch)
      end

      def license(repo)
        @content.license(repo)
      end

      def method_missing(name, ...)
        @client.public_send(name, ...)
      rescue ::Octokit::Unauthorized
        ::Kernel.raise ::Ask::Auth::InvalidCredential, :github_token
      end

      # BasicObject has no +respond_to?+ — report the content helpers
      # explicitly, forward everything else to the wrapped client.
      def respond_to?(name, include_private = false)
        CONTENT_METHODS.include?(name) || @client.respond_to?(name, include_private)
      end

      CONTENT_METHODS = %i[default_branch tree file license].freeze
    end
  end
end
