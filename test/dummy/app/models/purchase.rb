class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :store
  has_many :notifications, class_name: "Correspondent::Notification", as: :publisher
  notifies :user, %i[purchase], mailer: ApplicationMailer, if: :must_be_notified?
  notifies :store, :refund, mailer: ApplicationMailer, unless: -> { !must_be_notified? }

  def purchase
    yield if block_given?
    true
  end

  def refund
    (1..1000)
    .map { |i| i**2 }
    .reverse
    .uniq
    .reduce(:+)
  end

  def to_notification(entity:, trigger:)
    {
      title: "Purchase ##{id} for #{entity} #{send(entity).name}",
      content: "Congratulations on your recent #{trigger} of #{name}",
      image_url: "",
      link_url: "/purchases/#{id}",
      referrer_url: "/stores/#{store.id}"
    }
  end

  private

  def must_be_notified?
    true
  end
end
