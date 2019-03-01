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

    test ".create_for! single record" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase)

      assert !notification.respond_to?(:each)
      assert notification.is_a?(Correspondent::Notification)
      assert_equal publisher, notification.publisher
      assert_equal subscriber, notification.subscriber
      assert_equal "Purchase ##{publisher.id} for user user", notification.title
      assert_equal "Congratulations on your recent purchase of purchase", notification.content
    end

    test ".create_for! multiple records" do
      users = [
        User.create!(name: "user", email: "user@email.com"),
        User.create!(name: "user2", email: "user2@email.com")
      ]

      promotion = Promotion.create!(users: users, name: "promo")
      Correspondent::Notification.create_for!(promotion, :users, :promote)

      assert_equal 2, Correspondent::Notification.count

      assert_equal "Promotion ##{promotion.id} - promo", Correspondent::Notification.first.title
      assert_equal "promo is coming to you this spring", Correspondent::Notification.first.content

      Correspondent::Notification.create_for!(promotion, :users, :promote, avoid_duplicates: true)
      assert_equal 2, Correspondent::Notification.count
    end

    test ".create_for! with avoid duplicates" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase)
      assert notification.is_a?(Correspondent::Notification)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase, avoid_duplicates: true)
      assert_nil notification
    end

    test ".by_parents" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase)

      assert_includes Correspondent::Notification.by_parents(subscriber, publisher), notification
    end

    test "#as_json" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase)

      Rails.cache.delete(notification)

      assert_equal notification.attributes.except("updated_at", "subscriber_type", "subscriber_id"),
                   notification.as_json
    end

    test ".for_subscriber" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase)
      assert_includes Correspondent::Notification.for_subscriber("user", subscriber.id), notification
    end

    test "#dismiss!" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase)
      notification.dismiss!

      assert notification.dismissed
    end

    test ".not_dismissed" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification = Correspondent::Notification.create_for!(publisher, :user, :purchase)
      notification2 = Correspondent::Notification.create_for!(publisher, :user, :purchase)
      notification.dismiss!

      collection = Correspondent::Notification.not_dismissed
      assert_includes collection, notification2
      assert_not_includes collection, notification
    end
  end
end
