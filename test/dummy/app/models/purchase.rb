class Purchase < ApplicationRecord
  belongs_to :user
  has_many :notifications, class_name: "Correspondent::Notification", as: :publisher
  notifies :user, %i[purchase refund]

  def purchase
    true
  end

  def refund
    (1..1000)
    .map { |i| i**2 }
    .reverse
    .uniq
    .reduce(:+)
  end

  # :nocov:
  def dummy
    (1..1000)
    .map { |i| i**2 }
    .reverse
    .uniq
    .reduce(:+)
  end
  # :nocov:

  def to_notification(entity:, trigger:)
    {
      title: "Purchase ##{id} for #{entity} #{send(entity).name}",
      content: "Congratulations on your recent #{trigger} of #{name}",
      image_url: "",
      link_url: "/purchases/#{id}"
    }
  end
end
