# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100722050744) do

  create_table "checkout_events", :force => true do |t|
    t.string   "event"
    t.integer  "user_id"
    t.integer  "checkout_id"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checkouts", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_tags", :force => true do |t|
    t.string   "name"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.integer  "group_id"
    t.string   "filename"
    t.string   "mime_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_attendees", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.integer  "group_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
  end

  create_table "help_items", :force => true do |t|
    t.string   "display_text"
    t.string   "name"
    t.string   "anchor"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_categories", :force => true do |t|
    t.integer  "prefix"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_category_id"
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.text     "description"
    t.integer  "item_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "catalog_number"
  end

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "positions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
  end

  create_table "role_permissions", :force => true do |t|
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permission_id"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "group_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.string   "home_college"
    t.string   "smc"
    t.string   "graduation_year"
    t.string   "residence"
    t.string   "gender"
    t.date     "birthday"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
