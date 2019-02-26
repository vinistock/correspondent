class CreatePromotions < ActiveRecord::Migration[5.2]
  def change
    create_table :promotions do |t|
      t.string :name
    end

    create_join_table :promotions, :users do |t|
      t.index [:promotion_id, :user_id]
      t.index [:user_id, :promotion_id]
    end
  end
end
