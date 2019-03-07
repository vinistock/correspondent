# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_03_07_224854) do

  create_table "correspondent_notifications", force: :cascade do |t|
    t.string "title"
    t.string "content"
    t.string "image_url"
    t.boolean "dismissed", default: false
    t.string "publisher_type", null: false
    t.integer "publisher_id", null: false
    t.string "subscriber_type", null: false
    t.integer "subscriber_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link_url"
    t.string "referrer_url"
    t.index ["publisher_type", "publisher_id"], name: "index_correspondent_on_publisher"
    t.index ["subscriber_type", "subscriber_id"], name: "index_correspondent_on_subscriber"
  end

  create_table "promotions", force: :cascade do |t|
    t.string "name"
  end

  create_table "promotions_users", id: false, force: :cascade do |t|
    t.integer "promotion_id", null: false
    t.integer "user_id", null: false
    t.index ["promotion_id", "user_id"], name: "index_promotions_users_on_promotion_id_and_user_id"
    t.index ["user_id", "promotion_id"], name: "index_promotions_users_on_user_id_and_promotion_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "store_id"
    t.index ["store_id"], name: "index_purchases_on_store_id"
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
