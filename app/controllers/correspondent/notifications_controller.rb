# frozen_string_literal: true

require_dependency "correspondent/application_controller"

module Correspondent
  # NotificationsController
  #
  # API for all notifications related
  # endpoints.
  class NotificationsController < ApplicationController
    # index
    #
    # Returns all notifications for a given subscriber.
    def index
      notifications = Correspondent::Notification.for_subscriber(params[:subscriber_type], params[:subscriber_id])
      render(json: notifications) if stale?(notifications)
    end
  end
end
