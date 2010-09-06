class AddIndicies < ActiveRecord::Migration
  def self.up
    add_index :checkouts, :group_id
    add_index :checkouts, :user_id
    add_index :checkouts, :item_id

    add_index :event_attendees, :event_id
    add_index :event_attendees, :user_id

    add_index :events, :group_id

    add_index :feedposts, [:parent_id, :parent_type]

    add_index :help_items, :anchor, :unique => true

    add_index :item_categories, :parent_category_id
    
    add_index :items, :item_category_id
    add_index :items, :catalog_number

    add_index :positions, [:group_id, :user_id]

    add_index :role_permissions, :role_id
    add_index :role_permissions, :permission_id

    add_index :users, :andrewid, :unique => true

    add_index :watchers, [:item_id, :item_type]
    add_index :watchers, [:user_id]
  end

  def self.down
  end
end
