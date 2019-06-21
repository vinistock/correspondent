# frozen_string_literal: true

require_dependency "correspondent/application_controller"

module Correspondent
  # NotificationsController
  #
  # API for all notifications related
  # endpoints.
  class NotificationsController < ApplicationController
    before_action :find_notification, only: %i[dismiss destroy]

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
      @notification&.dismiss!
      head(:no_content)
    end

    # destroy
    #
    # Destroys a given notification.
    def destroy
      @notification&.destroy
      head(:no_content)
    end

    private

    def find_notification
      @notification = Correspondent::Notification.select(:id)
                                                 .find_by(id: params[:id])
    end
  end
end
