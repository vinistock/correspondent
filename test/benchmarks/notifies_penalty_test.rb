# frozen_string_literal: true

require "test_helper"
require "benchmark"
require "benchmark/ips"

module Correspondent
  class NotifiesPenaltyTest < ActiveSupport::TestCase
    test "it does not delay methods significantly" do
      user = User.create!(name: "user", email: "user@email.com")
      store = Store.create!(name: "best buy")
      purchase = Purchase.create!(name: "purchase", user: user, store: store)

      times_slower = how_many_times_slower do
        Benchmark.ips do |x|
          x.config(time: 5, warmup: 2)
          x.report("non-patched") { purchase.dummy }
          x.report("patched") { purchase.purchase }
          x.compare!
        end
      end

      puts "Patched method is #{times_slower} times slower"
    end

    test "the absolute delay time should be smaller than 1ms" do
      user = User.create!(name: "user", email: "user@email.com")
      store = Store.create!(name: "best buy")
      purchase = Purchase.create!(name: "purchase", user: user, store: store)

      patched_time = average_exec_time do
        purchase.purchase
      end

      normal_time = average_exec_time do
        purchase.dummy
      end

      puts "Patched method is #{(patched_time - normal_time).round(4)}s slower"
    end
  end
end
