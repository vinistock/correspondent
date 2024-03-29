# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../test/dummy/config/environment"
require "simplecov"
SimpleCov.start do
  add_filter("/test/")
end

ActiveRecord::Migrator.migrations_paths = [
  File.expand_path("../test/dummy/db/migrate", __dir__),
  File.expand_path("../db/migrate", __dir__)
]

require "rails/test_help"
require "minitest/mock"
require "purdytest"

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = "#{ActiveSupport::TestCase.fixture_path}/files"
  ActiveSupport::TestCase.fixtures :all
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    def setup
      ApplicationMailer.deliveries = []
    end
  end
end

# how_many_times_slower
#
# Traps $stdout into a StringIO
# object to extract how many times
# slower a method is in an IPS comparison.
def how_many_times_slower
  benchmark = StringIO.new
  original_stdout = $stdout
  $stdout = benchmark

  yield

  $stdout = original_stdout
  benchmark.string.scan(/(?<=- )[\d.]+(?=x\s+slower)/).first.to_f
end

# average_exec_time
#
# Calculate average execution time
# for a given block.
def average_exec_time(&block)
  (0...1000).sum do
    Benchmark.measure(&block).real
  end / 1000
end
