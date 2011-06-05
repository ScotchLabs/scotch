class EventAttendeesController < ApplicationController
  # GET /events/ID/event_attendees.json
  def index
    @event = Event.find(params[:event_id])
    
    respond_to do |format|
      format.json { render :json => {"event_id" => @event.id, "attendees" => @event.attendees.map{|u| {"name" => u.name, "andrewid" => u.andrewid} } } }
    end
  end
  
  # POST /events/1/event_attendees.json
  def create
    @event_attendee = EventAttendee.new
    @event_attendee.event = Event.find(params[:event_id])
    @event_attendee.user = current_user
    
    respond_to do |format|
      if @event_attendee.save
        format.json { render :json => {:event_attendee => @event_attendee, :username => current_user.name} }
      else
        format.json { render :json => @event_attendee.errors }
      end
    end
  end
  
  # DELETE /event_attendees/1.xml
  def destroy
    @event_attendee = EventAttendee.find(params[:id])
    @event_attendee.destroy
    
    respond_to do |format|
      format.xml { head :ok }
    end
  end
end
