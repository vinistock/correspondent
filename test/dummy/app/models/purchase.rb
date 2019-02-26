class Purchase < ApplicationRecord
  belongs_to :user
  has_many :notifications, class_name: "Correspondent::Notification", as: :publisher
  notifies :user, :purchase

  def purchase
    true
  end

  def to_notification(entity:, trigger:)
    {
      title: "Purchase ##{id} for #{entity} #{send(entity).name}",
      content: "Congratulations on your recent #{trigger} of #{name}",
      image_url: ""
    }
  end
end
