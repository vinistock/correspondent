# frozen_string_literal: true

require "test_helper"

module Correspondent
  class NotificationsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @subscriber = User.create!(name: "user", email: "user@email.com")
      store = Store.create!(name: "best buy")
      publisher = Purchase.create!(name: "purchase", user: @subscriber, store: store)
      data = { instance: publisher, entity: :user, trigger: :purchase }

      @notification1 = Correspondent::Notification.create_for!(data)
      @notification2 = Correspondent::Notification.create_for!(data)
      @notification3 = Correspondent::Notification.create_for!(data)
    end

    test "GET index" do
      get "/correspondent/user/#{@subscriber.id}/notifications", headers: { accept: "application/json" }

      body = JSON.parse(response.body)

      assert_response :ok
      assert_equal body[0]["id"], @notification3.id
      assert_equal body[1]["id"], @notification2.id
      assert_equal body[2]["id"], @notification1.id
      assert_includes response.headers, "eTag"
    end

    test "GET preview" do
      get "/correspondent/user/#{@subscriber.id}/notifications/preview", headers: { accept: "application/json" }

      body = JSON.parse(response.body)

      assert_response :ok
      assert_equal body["notification"]["id"], @notification3.id
      assert_equal(3, body["count"])
      assert_includes response.headers, "eTag"
    end

    test "PUT dismiss" do
      put "/correspondent/user/#{@subscriber.id}/notifications/#{@notification3.id}/dismiss",
          headers: { accept: "application/json" }

      assert_response :no_content
      assert Correspondent::Notification.find(@notification3.id).dismissed
    end

    test "DELETE destroy" do
      delete "/correspondent/user/#{@subscriber.id}/notifications/#{@notification3.id}",
             headers: { accept: "application/json" }

      assert_response :no_content
      assert_not Correspondent::Notification.exists?(id: @notification3.id)
    end
  end
end
