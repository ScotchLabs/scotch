class EventAttendeesController < ApplicationController
  # GET /event_attendees
  # GET /event_attendees.xml
  def index
    @event_attendees = EventAttendee.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event_attendees }
    end
  end

  # GET /event_attendees/1
  # GET /event_attendees/1.xml
  def show
    @event_attendee = EventAttendee.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event_attendee }
    end
  end

  # GET /event_attendees/new
  # GET /event_attendees/new.xml
  def new
    @event_attendee = EventAttendee.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event_attendee }
    end
  end

  # GET /event_attendees/1/edit
  def edit
    @event_attendee = EventAttendee.find(params[:id])
  end

  # POST /event_attendees
  # POST /event_attendees.xml
  def create
    @event_attendee = EventAttendee.new(params[:event_attendee])

    respond_to do |format|
      if @event_attendee.save
        format.html { redirect_to(@event_attendee, :notice => 'Event attendee was successfully created.') }
        format.xml  { render :xml => @event_attendee, :status => :created, :location => @event_attendee }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_attendee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /event_attendees/1
  # PUT /event_attendees/1.xml
  def update
    @event_attendee = EventAttendee.find(params[:id])

    respond_to do |format|
      if @event_attendee.update_attributes(params[:event_attendee])
        format.html { redirect_to(@event_attendee, :notice => 'Event attendee was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event_attendee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /event_attendees/1
  # DELETE /event_attendees/1.xml
  def destroy
    @event_attendee = EventAttendee.find(params[:id])
    @event_attendee.destroy

    respond_to do |format|
      format.html { redirect_to(event_attendees_url) }
      format.xml  { head :ok }
    end
  end
end
