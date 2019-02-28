# frozen_string_literal: true

require "test_helper"
require "benchmark"
require "benchmark/ips"

module Correspondent
  class NotifiesPenaltyTest < ActiveSupport::TestCase
    test "it does not delay methods significantly" do
      user = User.create!(name: "user", email: "user@email.com")
      purchase = Purchase.create!(name: "purchase", user: user)

      times_slower = how_many_times_slower do
        Benchmark.ips do |x|
          x.config(time: 5, warmup: 2)
          x.report("non-patched") { purchase.dummy }
          x.report("patched") { purchase.purchase }
          x.compare!
        end
      end

      assert_in_delta(3.5, times_slower, 1.5)
    end

    test "the absolute delay time should be smaller than 50ms" do
      user = User.create!(name: "user", email: "user@email.com")
      purchase = Purchase.create!(name: "purchase", user: user)

      patched_time = average_exec_time do
        purchase.purchase
      end

      normal_time = average_exec_time do
        purchase.dummy
      end

      assert patched_time - normal_time < 0.002
    end
  end
end
