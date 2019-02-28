class AddLinkUrlToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column(:correspondent_notifications, :link_url, :string)
  end
end
