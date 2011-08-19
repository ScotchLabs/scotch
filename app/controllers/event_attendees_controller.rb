class EventAttendeesController < ApplicationController
  # GET /events/ID/event_attendees.json
  def index
    @event = Event.find(params[:event_id])
    
    respond_to do |format|
      format.json {
        json = {"event_id" => @event.id, "attendees" => @event.attendees.map{|u| {:name => u.name, :andrewid => u.andrewid} } }
        json[:ref] = params[:ref] if params[:ref]
        render :json => json }
    end
  end
  
  # POST /events/1/event_attendees.json
  def create
    @event_attendee = EventAttendee.new
    @event_attendee.event = Event.find(params[:event_id])
    @event_attendee.user = current_user
    
    respond_to do |format|
      if @event_attendee.save
        format.json {
          json = { :event_attendee => @event_attendee, :username => current_user.name, :event_id => @event_attendee.event_id }
          json[:ref] = params[:ref] if params[:ref]
          render :json => json
        }
      else
        format.json {
          json = {:errors => @event_attendee.errors, :event_id => @event_attendee.event_id }
          json[:ref] = params[:ref] if params[:ref]
          render :json => json
        }
      end
    end
  end
  
  # DELETE /event_attendees/1.xml
  # DELETE /event_attendees/1.json
  def destroy
    @event_attendee = EventAttendee.find(params[:id])
    event_id =@event_attendee.event_id
    @group = @event_attendee.event.group
    require_permission "adminEvents" unless @event_attendee.user == current_user
    @event_attendee.destroy
    
    respond_to do |format|
      format.xml { head :ok }
      format.json {
        json = { :event_id => event_id }
        json[:ref] = params[:ref] if params[:ref]
        render :json => json
      }
      # TODO if it hasn't been deleted we need to tell the client, but this case only matters for data-injectors.
    end
  end
end
