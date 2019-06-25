# frozen_string_literal: true

require "test_helper"

module Correspondent
  class NotificationTest < ActiveSupport::TestCase
    def setup
      @subscriber = User.create!(name: "user", email: "user@email.com")
      store = Store.create!(name: "best buy")
      @publisher = Purchase.create!(name: "purchase", user: @subscriber, store: store)
    end

    test "accepts polymorphic association for publisher and subscriber" do
      notification = Notification.create!(publisher: @publisher, subscriber: @subscriber)

      assert notification.valid?
      assert_equal @publisher, notification.publisher
      assert_equal @subscriber, notification.subscriber
      assert_includes @subscriber.notifications, notification
      assert_includes @publisher.notifications, notification
    end

    test ".create_for! single record" do
      data = { instance: @publisher, entity: :user, trigger: :purchase }
      notification = Correspondent::Notification.create_for!(data)

      assert_not notification.respond_to?(:each)
      assert notification.is_a?(Correspondent::Notification)
      assert_equal @publisher, notification.publisher
      assert_equal @subscriber, notification.subscriber
      assert_equal "Purchase ##{@publisher.id} for user user", notification.title
      assert_equal "Congratulations on your recent purchase of purchase", notification.content
      assert_equal "/purchases/#{@publisher.id}", notification.link_url
      assert_equal "/stores/#{@publisher.store.id}", notification.referrer_url
    end

    test ".create_for! multiple records" do
      users = [
        User.create!(name: "user", email: "user@email.com"),
        User.create!(name: "user2", email: "user2@email.com")
      ]

      promotion = Promotion.create!(users: users, name: "promo")
      data = { instance: promotion, entity: :users, trigger: :promote }
      Correspondent::Notification.create_for!(data)

      assert_equal 2, Correspondent::Notification.count

      assert_equal "Promotion ##{promotion.id} - promo", Correspondent::Notification.first.title
      assert_equal "promo is coming to you this spring", Correspondent::Notification.first.content

      Correspondent::Notification.create_for!(data, avoid_duplicates: true)
      assert_equal 2, Correspondent::Notification.count
    end

    test ".create_for! with avoid duplicates" do
      data = { instance: @publisher, entity: :user, trigger: :purchase }
      notification = Correspondent::Notification.create_for!(data)
      assert notification.is_a?(Correspondent::Notification)

      notification = Correspondent::Notification.create_for!(data, avoid_duplicates: true)
      assert_nil notification
    end

    test ".by_parents" do
      data = { instance: @publisher, entity: :user, trigger: :purchase }
      notification = Correspondent::Notification.create_for!(data)

      assert_includes Correspondent::Notification.by_parents(@subscriber, @publisher), notification
    end

    test "#as_json" do
      data = { instance: @publisher, entity: :user, trigger: :purchase }
      notification = Correspondent::Notification.create_for!(data)

      Rails.cache.delete("correspondent_notification_#{notification.id}")

      assert_equal notification.attributes.except("updated_at", "subscriber_type", "subscriber_id"),
                   notification.as_json
    end

    test ".for_subscriber" do
      data = { instance: @publisher, entity: :user, trigger: :purchase }
      notification = Correspondent::Notification.create_for!(data)
      assert_includes Correspondent::Notification.for_subscriber("user", @subscriber.id), notification
    end

    test "#dismiss!" do
      data = { instance: @publisher, entity: :user, trigger: :purchase }
      notification = Correspondent::Notification.create_for!(data)
      notification.dismiss!

      assert notification.dismissed
    end

    test ".not_dismissed" do
      data = { instance: @publisher, entity: :user, trigger: :purchase }
      notification = Correspondent::Notification.create_for!(data)
      notification2 = Correspondent::Notification.create_for!(data)
      notification.dismiss!

      collection = Correspondent::Notification.not_dismissed
      assert_includes collection, notification2
      assert_not_includes collection, notification
    end
  end
end
