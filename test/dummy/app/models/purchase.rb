class Purchase < ApplicationRecord
  belongs_to :user
  has_many :notifications, class_name: "Correspondent::Notification", as: :publisher
  notifies :user, :purchase

  def purchase
    true
  end

  def to_notification
    {
      title: "Purchase ##{id} - #{name}",
      content: "Congratulations on your recent purchase of #{name}",
      image_url: ""
    }
  end
end
