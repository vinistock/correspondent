# frozen_string_literal: true

require "test_helper"

module Correspondent
  class NotificationTest < ActiveSupport::TestCase
    test "accepts polymorphic association for publisher and subscriber" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)
      notification = Notification.create!(publisher: publisher, subscriber: subscriber)

      assert notification.valid?
      assert_equal publisher, notification.publisher
      assert_equal subscriber, notification.subscriber
      assert_includes subscriber.notifications, notification
      assert_includes publisher.notifications, notification
    end
  end
end
