class EventsController < ApplicationController

  prepend_before_filter :locate_event, :only => [:edit, :update, :show, :destroy]

  before_filter :only => [:new, :edit, :create, :update, :destroy] do 
    require_permission "adminEvents"
  end

  # GET /group/1/events
  # GET /group/1/events.xml
  def index
    group_events = Event.where(:group_id => @group.id).order("start_time ASC")
    group_events = group_events.where(:title => params[:event_title]) unless params[:event_title].nil? or params[:event_title].empty?
    @events = group_events.where(["start_time > ?",Time.zone.now]).all
    @past_events = group_events.where(["start_time < ?",Time.zone.now]).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /group/1/events/new
  # GET /group/1/events/new.xml
  def new
    @event = Event.new
    @event.group = @group

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.xml
  def create
    @group = Group.find(params[:event][:group_id])

    if (params[:event_type] == "audition") then
      @events = Event.create_audition @group, params[:slot_count].to_i, params[:slot_length].to_i, params[:signups].to_i, params[:event]
      redirect_to(@group, :notice => "Events were successfully created.")
    else
      @event = Event.new(params[:event])
      @event.group = @group

      respond_to do |format|
        if @event.save
          format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
          format.xml  { render :xml => @event, :status => :created, :location => @event }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def signup

    @user = current_user
    @event_attendee = @event.event_attendees.where(:user_id => nil).first

    if @event_attendee.nil? 
      redirect_to @event, :notice => "No free slots available."
      return
    end

    @event_attendee.user = @user

    respond_to do |format|
      if @event_attendee.save
        format.html { redirect_to(@event, :notice => 'You are now signed up.') }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@event, :notice => 'Unable to signup.') }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  def locate_event
    @event = Event.find(params[:id]) if params[:id]
    @group = @event.group if @group.nil?
  end
end
