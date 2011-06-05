module EventsHelper
  def squish_events(all_events)
    # make sure our events are in order
    all_events.sort!

    # keep going until we are out of events
    while (all_events.length > 0) do
      # slide all elements off of the front of all_events with the same title
      # and adjacent start/end times
      events = [all_events.shift]
      while (all_events.length > 0 && all_events[0].title == events[0].title && all_events[0].start_time == events[-1].end_time) do
        events.push all_events.shift
      end

      yield(events)

    end
  end
  
  def event_to_json(event)
    ea=-1
    if event.attendees.include? current_user
      ea=EventAttendee.where(:event_id => event.id, :user_id => current_user.id).first.id
    end
    
    return "{\"id\": #{event.id},
      \"group_id\": \"#{event.group.id}\",
      \"title\" : \"[#{event.group.short_name}] #{event.title}\", 
      \"start\" : \"#{event.start_time.to_datetime}\", 
      \"end\" : \"#{event.end_time.to_datetime}\",
      \"className\": \"#{event.className}\",
      \"group\": \"#{event.group.name}\",
      \"location\":\"#{event.location}\",
      \"privacyType\":\"#{event.privacy_type}\",
      \"attendeeLimit\":\"#{event.attendee_limit}\",
      \"numAttendees\":\"#{event.attendees.count}\",
      \"currentUserAttending\":#{ea},
      \"allDay\":\"#{event.all_day}\"}"
  end
end
