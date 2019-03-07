# frozen_string_literal: true

class Store < ApplicationRecord
  has_many :purchases
  has_many :notifications, class_name: "Correspondent::Notification", as: :subscriber
end
