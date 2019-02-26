class Promotion < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :notifications, class_name: "Correspondent::Notification", as: :publisher
  notifies :users, :promote

  def promote
    true
  end

  def to_notification
    {
      title: "Promotion ##{id} - #{name}",
      content: "#{name} is coming to you this spring",
      image_url: ""
    }
  end
end
