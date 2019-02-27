# frozen_string_literal: true

require "test_helper"
require "benchmark/ips"

module Correspondent
  class NotifiesPenaltyTest < ActiveSupport::TestCase
    test "it does not delay methods significantly" do
      user = User.create!(name: "user", email: "user@email.com")
      purchase = Purchase.create!(name: "purchase", user: user)

      times_slower = how_many_times_slower do
        Benchmark.ips do |x|
          x.report("non-patched") { purchase.dummy }
          x.report("patched") { purchase.purchase }
          x.compare!
        end
      end

      assert_in_delta(8.5, times_slower, 1.5)
    end
  end
end
