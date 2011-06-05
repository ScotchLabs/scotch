class EventsController < ApplicationController
  include EventsHelper
  
  prepend_before_filter :locate_event, :only => [:edit, :update, :show, :destroy, :signup, :create]

  before_filter :only => [:new, :edit, :create, :update, :destroy] do 
    require_permission "adminEvents"
  end

  # GET /group/1/events
  # GET /group/1/events.xml
  # GET /group/1/events.json
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
  # POST /events.json
  def create
    @group = Group.find(params[:event][:group_id])

    @event = Event.new(params[:event])
    @event.group = @group
    @event.attendees = @group.users.where("positions.display_name" => params[:position_names]).uniq
    
    @events = Array.new
    @events.push @event
    
    respond_to do |format|
      if @event.save
        @event.propagate if params[:repeat]=="1"
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

  # PUT /events/1
  # PUT /events/1.xml
  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])
        if params[:all]=="1"
          c = @event.repeat_parent.repeat_children.where(["start_time > ?",e.start_time])
          c.each do |e|
            e.repeat_id = @event.id
          end
          @event.propagate
        end
        @event.repeat_id = nil
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
    if params[:all]=="1"
      c = @event.repeat_parent.repeat_children.where(["start_time > ?",e.start_time])
      c.destroy_all
    end
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(group_events_url(@event.group)) }
      format.xml  { head :ok }
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
