# frozen_string_literal: true

require "test_helper"

module Correspondent
  class NotificationsControllerTest < ActionDispatch::IntegrationTest
    test "GET index" do
      subscriber = User.create!(name: "user", email: "user@email.com")
      publisher = Purchase.create!(name: "purchase", user: subscriber)

      notification1 = Correspondent::Notification.create_for!(publisher, :user, :purchase)
      notification2 = Correspondent::Notification.create_for!(publisher, :user, :purchase)
      notification3 = Correspondent::Notification.create_for!(publisher, :user, :purchase)

      get "/correspondent/user/#{subscriber.id}/notifications", headers: { accept: "application/json" }

      body = JSON.parse(response.body)

      assert_response :ok
      assert_equal body[0]["id"], notification3.id
      assert_equal body[1]["id"], notification2.id
      assert_equal body[2]["id"], notification1.id
      assert_includes response.headers, "eTag"
    end
  end
end
