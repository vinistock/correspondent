class Purchase < ApplicationRecord
  belongs_to :user
  has_many :notifications, class_name: "Correspondent::Notification", as: :publisher
  notifies :user, :purchase

  def purchase
    true
  end
end
