class User < ApplicationRecord
  has_and_belongs_to_many :promotions
  has_many :purchases
  has_many :notifications, class_name: "Correspondent::Notification", as: :subscriber
end
