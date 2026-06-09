require_relative "coverage_helper"
# frozen_string_literal: true


SimpleCov.at_exit do
  SimpleCov.result.format!
  coverage = SimpleCov.result.covered_percent
  puts "
Coverage: #{coverage.round(2)}%"
  if coverage < 90
    puts "WARNING: Coverage below 90%!"
    exit 1
  end
end
