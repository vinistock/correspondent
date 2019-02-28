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

    # preview
    #
    # Returns the newest notification and the total
    # number of notifications for the given subscriber.
    def preview
      notifications = Correspondent::Notification.for_subscriber(params[:subscriber_type], params[:subscriber_id])

      if stale?(notifications)
        render(
          json: {
            count: notifications.count,
            notification: notifications.limit(1).first
          }
        )
      end
    end

    # dismiss
    #
    # Dismisses a given notification.
    def dismiss
      Correspondent::Notification.select(:id)
                                 .where(id: params[:id])
                                 .first
                                 &.dismiss!

      head(:no_content)
    end
  end
end
