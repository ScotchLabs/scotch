class RemoveDuplicateEventAttendees < ActiveRecord::Migration
  def self.up
    if EventAttendee.exists?(:id => 3934)
      ea=EventAttendee.find(3934)
      ea.destroy
    end
  end

  def self.down
  end
end
