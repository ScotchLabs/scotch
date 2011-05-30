class EventAttendeesController < ApplicationController
  # GET /events/ID/event_attendees.json
  def index
    @event = Event.find(params[:event_id])
    
    respond_to do |format|
      format.json { render :json => {"event_id" => @event.id, "attendees" => @event.attendees.map{|u| {"name" => u.name, "andrewid" => u.andrewid} } } }
    end
  end
end