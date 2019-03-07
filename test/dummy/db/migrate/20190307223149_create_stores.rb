class CreateStores < ActiveRecord::Migration[5.2]
  def change
    create_table :stores do |t|
      t.string :name
    end

    change_table :purchases do |t|
      t.references :store
    end
  end
end
