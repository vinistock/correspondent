# frozen_string_literal: true

module Correspondent
  # Notification
  #
  # Model to hold all notification logic.
  class Notification < ApplicationRecord
    belongs_to :subscriber, polymorphic: true
    belongs_to :publisher, polymorphic: true

    validates_presence_of :publisher, :subscriber
  end
end
