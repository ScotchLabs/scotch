class RemoveDuplicateEventAttendees < ActiveRecord::Migration
  def self.up
    # duplicate ea was found with sql in pma
    ea=EventAttendee.find(3934)
    ea.destroy!
  end

  def self.down
  end
end
