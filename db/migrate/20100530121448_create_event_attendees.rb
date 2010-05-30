class CreateEventAttendees < ActiveRecord::Migration
  def self.up
    create_table :event_attendees do |t|
      t.integer :event_id
      t.integer :user_id
      t.string :kind

      t.timestamps
    end
  end

  def self.down
    drop_table :event_attendees
  end
end
