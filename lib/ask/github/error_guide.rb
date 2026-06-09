# frozen_string_literal: true

module Ask
  module GitHub
    # Structured error knowledge for AI agents working with the GitHub API.
    #
    # Provides human-readable guidance for common HTTP status codes, rate
    # limiting, pagination, and authentication errors encountered when
    # using the Octokit client.
    module Errors
      # Rate limit information.
      #
      # - Authenticated requests: 5,000 requests per hour
      # - Unauthenticated requests: 60 requests per hour
      #
      # When rate-limited, +Octokit::TooManyRequests+ is raised. The agent
      # should wait for the reset time and retry.
      RATE_LIMIT = {
        authenticated: "5,000 requests per hour (using personal access token)",
        anonymous: "60 requests per hour (no authentication)",
        error_class: "Octokit::TooManyRequests",
        action: "Wait for the rate limit reset window, then retry the request."
      }.freeze

      # Common HTTP status codes returned by the GitHub API and how to handle them.
      STATUS_CODES = {
        200 => "OK — Request succeeded.",
        201 => "Created — Resource was created successfully.",
        202 => "Accepted — Request accepted for processing (async operations).",
        204 => "No Content — Request succeeded, no response body.",
        301 => "Moved Permanently — The resource URL has changed; update your reference.",
        304 => "Not Modified — Cached response is still valid (conditional request).",
        401 => "Unauthorized — Token is missing, invalid, or revoked. Re-authenticate.",
        403 => "Forbidden — Token lacks required scopes. Check token permissions.",
        404 => "Not Found — Resource does not exist or is private.",
        409 => "Conflict — Resource state conflict (e.g., merge conflict).",
        410 => "Gone — Resource was removed permanently.",
        422 => "Unprocessable Entity — Validation failed. Check request parameters.",
        429 => "Too Many Requests — Rate limit exceeded. Wait before retrying.",
        500 => "Internal Server Error — GitHub server issue. Retry with backoff.",
        502 => "Bad Gateway — GitHub upstream issue. Retry with backoff.",
        503 => "Service Unavailable — GitHub is down for maintenance. Retry later."
      }.freeze

      # Pagination guidance for large result sets.
      PAGINATION = {
        auto_paginate: "Octokit::Client is configured with auto_paginate: true by default.",
        per_page: "Maximum items per page is 100. The default client uses 100.",
        link_header: "GitHub uses Link headers for pagination. Octokit handles this automatically.",
        max_results: "For very large queries, iterate pages or use GitHub's search API."
      }.freeze

      # Map of Octokit exception classes to human-readable guidance.
      EXCEPTIONS = {
        "Octokit::Unauthorized" => {
          message: "Your GitHub token is invalid or has been revoked.",
          action: "Generate a new token at https://github.com/settings/tokens with the 'repo' and 'read:org' scopes."
        },
        "Octokit::Forbidden" => {
          message: "Your token lacks the required permissions for this operation.",
          action: "Check your token scopes at https://github.com/settings/tokens. You may need additional scopes."
        },
        "Octokit::NotFound" => {
          message: "The requested repository, issue, or resource does not exist or is private.",
          action: "Verify the owner/repo name and that the repository is accessible with your token."
        },
        "Octokit::TooManyRequests" => {
          message: "GitHub API rate limit exceeded.",
          action: "Check X-RateLimit-Reset header, wait until that timestamp, then retry. Authenticated requests get 5,000/hr."
        },
        "Octokit::UnprocessableEntity" => {
          message: "The request body failed validation.",
          action: "Check required fields, data types, and constraints. GitHub returns detailed error messages in the response body."
        },
        "Octokit::ServerError" => {
          message: "GitHub encountered a server error.",
          action: "Retry with exponential backoff. If the issue persists, check https://www.githubstatus.com."
        },
        "Octokit::InvalidRepository" => {
          message: "The repository name format is invalid.",
          action: "Use the format 'owner/repo' (e.g., 'octocat/hello-world')."
        }
      }.freeze

      # Look up guidance for an exception class name.
      #
      # @param exception_class [String] The exception class name (e.g., "Octokit::NotFound")
      # @return [Hash, nil] A hash with +:message+ and +:action+ keys, or nil if unknown
      def self.for(exception_class)
        EXCEPTIONS[exception_class]
      end

      # Describe an HTTP status code.
      #
      # @param code [Integer] HTTP status code
      # @return [String, nil] Description of the status code
      def self.status_code_description(code)
        STATUS_CODES[code]
      end
    end
  end
end
