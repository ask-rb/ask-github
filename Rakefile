require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

desc "Run tests with coverage"
task :coverage do
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/lib/ask/github/version.rb"
    track_files "lib/**/*.rb"
  end

  Rake::Task[:test].invoke

  SimpleCov.at_exit do
    SimpleCov.result.format!
    coverage = SimpleCov.result.covered_percent
    puts "\nLine coverage: #{coverage.round(2)}%"
  end
end

task default: :test

desc "Build and install the gem locally"
task :install => :build do
  sh "gem install pkg/ask-github-#{Ask::GitHub::VERSION}.gem"
end

desc "Push the gem to RubyGems"
task :release => :build do
  sh "gem push pkg/ask-github-#{Ask::GitHub::VERSION}.gem"
end
