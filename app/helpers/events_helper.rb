module EventsHelper
  def squish_events(all_events)
    # make sure our events are in order
    all_events.sort!

    # keep going until we are out of events
    while (all_events.length > 0) do
      # slide all elements off of the front of all_events that are repeat_children (or siblings) of the first
      events = [all_events.shift]
      while (all_events.length > 0 and
        all_events[0].start_time.strftime("%D")==events[0].start_time.strftime("%D") and # repeated events that cross into a new day get a new badge
        all_events[0].repeat_id != nil and (events[0].id == all_events[0].repeat_id or events[0].repeat_id == all_events[0].repeat_id) ) do # repeated events on the same day list together
        events.push all_events.shift
      end

      yield(events)

    end
  end
  
  def event_to_json(event)
    ea=-1
    if event.attendees.include? current_user
      # we pass an id and not a T/F value so that the user can
      # delete his EventAttendee record
      ea=EventAttendee.where(:event_id => event.id, :user_id => current_user.id).first.id
    end
    
    return "{\"id\": #{event.id},
      \"group_id\": \"#{event.group.id}\",
      \"title\" : \"[#{event.group.short_name}] #{event.title}\", 
      \"start\" : \"#{event.start_time.to_datetime}\",
      \"formattedStart\" : \"#{(event.all_day)? format_date(event.start_time,true):format_time(event.start_time,true)}\", 
      \"end\" : \"#{event.end_time.to_datetime}\",
      \"formattedEnd\" : \"#{(event.all_day)? format_date(event.end_time,true):format_time(event.end_time,true)}\",
      \"className\": \"#{event.className}\",
      \"group\": \"#{event.group.name}\",
      \"location\":\"#{event.location}\",
      \"privacyType\":\"#{event.privacy_type}\",
      \"attendeeLimit\":\"#{event.attendee_limit}\",
      \"numAttendees\":\"#{event.attendees.count}\",
      \"repeatId\":#{event.repeat_id or 0},
      \"currentUserAttending\":#{ea},
      \"allDay\":#{event.all_day or false},
      \"editable\":#{(has_permission? "adminEvents")? true : false},
      \"description\":#{RedCloth.new(event.description).gsub(/\n/,"<br>").to_json}}"
  end
end
