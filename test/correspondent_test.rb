# frozen_string_literal: true

require "test_helper"

module Correspondent
  class Test < ActiveSupport::TestCase
    test "adds hook to extend module after ar load" do
      purchase = Purchase.new
      assert defined?(purchase.class.notifies)
    end

    test "#notifies" do
      user = User.create!(name: "user", email: "user@email.com")
      store = Store.create!(name: "best buy")
      purchase = Purchase.create!(name: "purchase", user: user, store: store)

      method_source = purchase.method(:purchase).source
      assert_includes(method_source, "async_calls")
      assert(purchase.purchase { 5**5 })

      method_source = purchase.method(:refund).source
      assert_includes(method_source, "async_calls")
      assert purchase.refund

      assert_equal 2, ApplicationMailer.deliveries.count

      assert_equal 1, store.notifications.count
      assert_equal 1, user.notifications.count
      assert_equal 2, purchase.notifications.count
    end

    test "#notifies for many to many" do
      users = [
        User.create!(name: "user", email: "user@email.com"),
        User.create!(name: "user2", email: "user2@email.com")
      ]

      promotion = Promotion.create!(users: users, name: "promo")

      method_source = promotion.method(:promote).source
      assert_includes(method_source, "async_calls")
      assert promotion.promote

      assert_equal 0, ApplicationMailer.deliveries.count
    end

    test "#notifies when an error is raised" do
      user = User.create!(name: "user", email: "user@email.com")
      store = Store.create!(name: "best buy")
      purchase = Purchase.create!(name: "purchase", user: user, store: store)

      raises_exception = -> { raise StandardError, "Test error" }

      purchase.stub :purchase, raises_exception do
        assert_raises(StandardError) { purchase.purchase }
        assert_equal 0, Correspondent::Notification.count
      end
    end
  end
end
