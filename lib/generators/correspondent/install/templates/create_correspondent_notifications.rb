class CreateCorrespondentNotifications < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :correspondent_notifications do |t|
      t.string :title
      t.string :content
      t.string :image_url
      t.string :link_url
      t.string :referrer_url
      t.boolean :dismissed, default: false
      t.string :publisher_type, null: false
      t.integer :publisher_id, null: false
      t.string :subscriber_type, null: false
      t.integer :subscriber_id, null: false
      t.index [:publisher_type, :publisher_id], name: "index_correspondent_on_publisher"
      t.index [:subscriber_type, :subscriber_id], name: "index_correspondent_on_subscriber"
      t.timestamps
    end
  end
end
