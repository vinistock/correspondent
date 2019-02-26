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
      purchase = Purchase.create!(name: "purchase", user: user)

      method_source = purchase.method(:purchase).source
      assert method_source.include?("ActiveSupport::Notifications.instrument")
      assert purchase.purchase

      method_source = purchase.method(:refund).source
      assert method_source.include?("ActiveSupport::Notifications.instrument")
      assert purchase.refund
    end

    test "#notifies for many to many" do
      users = [
        User.create!(name: "user", email: "user@email.com"),
        User.create!(name: "user2", email: "user2@email.com")
      ]

      promotion = Promotion.create!(users: users, name: "promo")

      method_source = promotion.method(:promote).source
      assert method_source.include?("ActiveSupport::Notifications.instrument")
      assert promotion.promote
    end
  end
end
