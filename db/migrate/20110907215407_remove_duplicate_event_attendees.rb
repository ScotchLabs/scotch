class RemoveDuplicateEventAttendees < ActiveRecord::Migration
  def self.up
    ea=EventAttendee.find(3934)
    ea.destroy
  end

  def self.down
  end
end
