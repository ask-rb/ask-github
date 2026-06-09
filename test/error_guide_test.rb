# frozen_string_literal: true

require_relative "test_helper"

class ErrorGuideTest < Minitest::Test
  def test_rate_limit_authenticated
    assert_includes Ask::GitHub::Errors::RATE_LIMIT[:authenticated], "5,000"
  end

  def test_rate_limit_anonymous
    assert_includes Ask::GitHub::Errors::RATE_LIMIT[:anonymous], "60"
  end

  def test_rate_limit_has_error_class
    assert_equal "Octokit::TooManyRequests", Ask::GitHub::Errors::RATE_LIMIT[:error_class]
  end

  def test_status_codes_cover_common_codes
    [200, 201, 204, 301, 401, 403, 404, 422, 429, 500, 502, 503].each do |code|
      assert Ask::GitHub::Errors::STATUS_CODES.key?(code), "Missing status code #{code}"
    end
  end

  def test_status_code_description_returns_string
    desc = Ask::GitHub::Errors.status_code_description(404)
    assert_match(/Not Found/, desc)
  end

  def test_status_code_description_returns_nil_for_unknown
    assert_nil Ask::GitHub::Errors.status_code_description(999)
  end

  def test_exceptions_cover_common_errors
    %w[
      Octokit::Unauthorized
      Octokit::Forbidden
      Octokit::NotFound
      Octokit::TooManyRequests
      Octokit::UnprocessableEntity
      Octokit::ServerError
      Octokit::InvalidRepository
    ].each do |klass|
      assert Ask::GitHub::Errors::EXCEPTIONS.key?(klass), "Missing exception #{klass}"
    end
  end

  def test_for_returns_guidance
    guidance = Ask::GitHub::Errors.for("Octokit::NotFound")
    assert guidance.key?(:message)
    assert guidance.key?(:action)
  end

  def test_for_returns_nil_for_unknown
    assert_nil Ask::GitHub::Errors.for("Some::Unknown::Error")
  end

  def test_exception_messages_are_helpful
    error = Ask::GitHub::Errors.for("Octokit::Unauthorized")
    assert_includes error[:action], "github.com/settings/tokens"
  end

  def test_pagination_info_is_defined
    assert Ask::GitHub::Errors::PAGINATION.key?(:auto_paginate)
    assert Ask::GitHub::Errors::PAGINATION.key?(:per_page)
    assert Ask::GitHub::Errors::PAGINATION.key?(:link_header)
  end
end
