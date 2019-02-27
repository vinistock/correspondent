# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "simplecov"
SimpleCov.start

require_relative "../test/dummy/config/environment"

ActiveRecord::Migrator.migrations_paths = [
  File.expand_path("../test/dummy/db/migrate", __dir__),
  File.expand_path("../db/migrate", __dir__)
]

require "rails/test_help"
require "minitest/mock"
require "byebug"
require "purdytest"

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
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
