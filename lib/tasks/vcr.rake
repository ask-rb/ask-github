# frozen_string_literal: true

namespace :vcr do
  desc "Record VCR cassettes for a specific provider"
  task :record, [:provider] do |_t, args|
    provider = args[:provider] || "all"
    cassette_dir = File.expand_path("../../test/cassettes", __dir__)

    if provider == "all"
      puts "Removing all cassettes..."
      FileUtils.rm_rf(Dir[File.join(cassette_dir, "*.yml")])
    else
      puts "Removing cassettes for #{provider}..."
      FileUtils.rm_rf(Dir[File.join(cassette_dir, "*#{provider}*.yml")])
    end

    puts "Running tests to re-record cassettes..."
    system("bundle exec rake test")
  end

  desc "Verify cassettes are fresh (less than 30 days old)"
  task :verify_freshness do
    cassette_dir = File.expand_path("../../test/cassettes", __dir__)
    stale = false

    Dir[File.join(cassette_dir, "*.yml")].each do |cassette|
      age_days = (Time.now - File.mtime(cassette)) / 86400.0
      if age_days > 30
        puts "STALE: #{File.basename(cassette)} is #{age_days.round(1)} days old"
        stale = true
      end
    end

    if stale
      puts "\nSome cassettes are older than 30 days. Re-record them with:"
      puts "  bundle exec rake vcr:record[all]"
      exit 1
    else
      puts "All cassettes are fresh (less than 30 days old)."
    end
  end
end
