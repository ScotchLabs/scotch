class EventsController < ApplicationController
  include EventsHelper
  
  prepend_before_filter :locate_event, :only => [:edit, :update, :show, :destroy, :signup, :create]

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
      format.json {
        json_events = group_events.clone
        # params sent by fullCalendar
        json_events = json_events.select{|e| e.start_time >= Time.at(params[:start].to_i)} if params[:start]
        json_events = json_events.select{|e| e.end_time <= Time.at(params[:end].to_i)} if params[:end]
        
        json = json_events.collect { |e| event_to_json(e) }.join(",\n")
        json = "{\"group_id\" : #{@group.id},\n\"events\" : [#{json}]}"
        
        render :json => json
      }
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
      @event.attendees = @group.users.where("positions.display_name" => params[:position_names]).uniq
      
      @events = Array.new
      @events.push @event
      
      respond_to do |format|
        if @event.save
          if params[:repeat]=="1"
            change = @event.repeat_period
            delta = @event.repeat_frequency
            if params[:stop_condition_type] == "date"
              tempTime = @event.end_time
              goal = @event.stop_on_date
              n=0
              while tempTime < goal
                n=n+1
                tempTime = tempTime.advance(change.to_sym => delta)
              end
            else
              n=@event.stop_after_occurrences-1
            end
            g=@event.clone
            g.repeat_id = @event.id
            g.repeat_period = nil
            g.repeat_frequency = nil
            g.stop_after_occurrences = nil
            g.stop_on_date = nil
            n.times do
              g=g.clone
              g.start_time = g.start_time.advance(change.to_sym => delta)
              g.end_time = g.end_time.advance(change.to_sym => delta)
              @events.push g if g.save
            end
          end
          format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
          format.xml  { render :xml => @event, :status => :created, :location => @event }
          format.json {
            json = @events.collect { |e| event_to_json(e) }.join(",\n")
            json = "{\"group_id\" : #{@group.id},\n\"events\" : [#{json}]}"
            render :json => json
          }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
          format.json { render :json => @event.errors }
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
      format.html { redirect_to(group_events_url(@event.group)) }
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
    @group = @event.group if @event and @group.nil?

    # FIXME this is ugly
    if @group.nil? and params.has_key? :event and params[:event].has_key? :group_id then
      @group = Group.find(params[:event][:group_id])
    end
  end
end
