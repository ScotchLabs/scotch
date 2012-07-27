# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120727232124) do

  create_table "checkouts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "checkout_date"
    t.date     "checkin_date"
    t.text     "notes"
  end

  add_index "checkouts", ["item_id"], :name => "index_checkouts_on_item_id"
  add_index "checkouts", ["user_id"], :name => "index_checkouts_on_user_id"

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "description"
    t.integer  "folder_id"
  end

  create_table "event_attendees", :force => true do |t|
    t.integer  "event_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "event_attendees", ["event_id"], :name => "index_event_attendees_on_event_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "attendee_limit"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "event_type"
    t.string   "session"
    t.string   "session_name"
  end

  create_table "feedpost_attachments", :force => true do |t|
    t.integer  "feedpost_id"
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedposts", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "post_type"
    t.string   "headline"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent_type"
    t.string   "privacy",        :default => "All"
    t.text     "recipient_ids"
    t.integer  "reference_id"
    t.string   "reference_type"
  end

  add_index "feedposts", ["parent_id", "parent_type"], :name => "index_feedposts_on_parent_id_and_parent_type"

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "folder_id"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
    t.date     "archive_date"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "script_id"
    t.string   "slot"
    t.integer  "price_with_id"
    t.integer  "price_without_id"
    t.string   "location"
    t.date     "tech_start"
    t.date     "tech_end"
  end

  create_table "help_items", :force => true do |t|
    t.string   "display_text"
    t.string   "name"
    t.string   "anchor"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "help_items", ["anchor"], :name => "index_help_items_on_anchor", :unique => true

  create_table "item_categories", :force => true do |t|
    t.integer  "prefix"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_category_id"
  end

  add_index "item_categories", ["parent_category_id"], :name => "index_item_categories_on_parent_category_id"

  create_table "items", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.text     "description"
    t.integer  "item_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "catalog_number"
  end

  add_index "items", ["catalog_number"], :name => "index_items_on_catalog_number"
  add_index "items", ["item_category_id"], :name => "index_items_on_item_category_id"

  create_table "kawards", :force => true do |t|
    t.integer  "kudo_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "knominations", :force => true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kaward_id"
    t.boolean  "deleted",    :default => false
  end

  create_table "knominations_users", :id => false, :force => true do |t|
    t.integer "knomination_id"
    t.integer "user_id"
  end

  create_table "kudos", :force => true do |t|
    t.datetime "nominations_open"
    t.datetime "start"
    t.datetime "end"
    t.datetime "woodscotch"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kvoters", :force => true do |t|
    t.integer  "user_id"
    t.integer  "kudo_id"
    t.boolean  "has_voted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kvotes", :force => true do |t|
    t.integer  "knomination_id"
    t.boolean  "positive"
    t.string   "stage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "message_threads", :force => true do |t|
    t.string   "subject"
    t.integer  "group_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "privacy",    :default => "none"
    t.boolean  "deleted",    :default => false
  end

  create_table "message_threads_users", :id => false, :force => true do |t|
    t.integer  "message_thread_id"
    t.integer  "user_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.string   "priority"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "message_thread_id"
  end

  create_table "nominations", :force => true do |t|
    t.integer  "race_id"
    t.text     "platform"
    t.string   "tagline"
    t.boolean  "accepted",    :default => false
    t.boolean  "winner",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "votes_count", :default => 0
  end

  create_table "nominators", :id => false, :force => true do |t|
    t.integer "knomination_id"
    t.integer "user_id"
  end

  create_table "nominees", :force => true do |t|
    t.integer  "user_id"
    t.integer  "nomination_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "write_in"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "action"
    t.string   "text"
    t.boolean  "read",         :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
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

  add_index "positions", ["group_id", "user_id"], :name => "index_positions_on_group_id_and_user_id"

  create_table "races", :force => true do |t|
    t.integer  "voting_id"
    t.string   "name"
    t.integer  "grouping"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "write_in_available"
  end

  create_table "role_permissions", :force => true do |t|
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permission_id"
  end

  add_index "role_permissions", ["permission_id"], :name => "index_role_permissions_on_permission_id"
  add_index "role_permissions", ["role_id"], :name => "index_role_permissions_on_role_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "group_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",                       :null => false
    t.text     "value"
    t.integer  "target_id"
    t.string   "target_type", :limit => 30
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "settings", ["target_type", "target_id", "var"], :name => "index_settings_on_target_type_and_target_id_and_var", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",   :null => false
    t.string   "encrypted_password",    :limit => 128, :default => "",   :null => false
    t.string   "password_salt",                        :default => ""
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
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
    t.boolean  "public_profile",                       :default => true, :null => false
    t.string   "headshot_file_name"
    t.string   "headshot_content_type"
    t.integer  "headshot_file_size"
    t.datetime "headshot_updated_at"
    t.string   "andrewid"
    t.string   "majors"
    t.string   "minors"
    t.string   "other_activities"
    t.text     "about"
    t.boolean  "email_notifications",                  :default => true, :null => false
  end

  add_index "users", ["andrewid"], :name => "index_users_on_andrewid", :unique => true
  add_index "users", ["birthday"], :name => "index_users_on_birthday"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "voters", :id => false, :force => true do |t|
    t.integer "kaward_id"
    t.integer "user_id"
  end

  create_table "votes", :force => true do |t|
    t.integer  "nomination_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "votings", :force => true do |t|
    t.string   "name"
    t.date     "open_date"
    t.date     "close_date"
    t.date     "vote_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "voting_type"
    t.date     "press_date"
    t.integer  "group_id",    :null => false
  end

  create_table "watchers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "item_type"
  end

  add_index "watchers", ["item_id", "item_type"], :name => "index_watchers_on_item_id_and_item_type"
  add_index "watchers", ["user_id"], :name => "index_watchers_on_user_id"

end
