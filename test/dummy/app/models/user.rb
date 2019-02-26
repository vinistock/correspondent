class User < ApplicationRecord
  has_many :purchases
  has_many :notifications, class_name: "Correspondent::Notification", as: :subscriber
end
