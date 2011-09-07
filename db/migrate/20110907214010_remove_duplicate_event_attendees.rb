class RemoveDuplicateEventAttendees < ActiveRecord::Migration
  def self.up
    # I'm not sure how to elegantly select duplicates in Rails query language,
    # so I went to PMA and ran the following sql:
    # SELECT user_id,event_id FROM event_attendees GROUP BY user_id,event_id HAVING COUNT(*)>1;
    # The result led me to a certain event_attendee id which is referenced here
    ea=EventAttendees.find(3934)
    ea.destroy!
  end

  def self.down
  end
end
