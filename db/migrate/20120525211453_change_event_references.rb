class ChangeEventReferences < ActiveRecord::Migration
  def self.up
    remove_column :events, :group_id
    remove_column :event_attendees, :user_id
    
    add_column :events, :owner_id, :integer
    add_column :events, :owner_type, :string
    add_column :event_attendees, :owner_id, :integer
    add_column :event_attendees, :owner_type, :string
  end

  def self.down
    remove_column :events, :owner_id
    remove_column :events, :owner_type
    remove_column :event_attendees, :owner_id
    remove_column :event_attendees, :owner_type
    
    add_column :events, :group_id, :integer
    add_column :event_attendees, :user_id, :integer
  end
end
