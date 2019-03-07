class AddReferrerUrlToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column(:correspondent_notifications, :referrer_url, :string)
  end
end
