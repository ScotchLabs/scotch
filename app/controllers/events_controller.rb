class EventsController < ApplicationController
  include EventsHelper
  include ApplicationHelper
  
  prepend_before_filter :locate_event, :only => [:edit, :update, :show, :destroy, :signup, :create]

  before_filter :only => [:new, :edit, :create, :update, :destroy] do 
    require_permission "adminEvents"
  end

  # GET /group/1/events
  # GET /group/1/events.xml
  # GET /group/1/events.json
  def index
    if @group
      group_events = Event.where(:group_id => @group.id).order("start_time ASC")
    elsif params[:group_ids]
      group_events = Event.where(:group_id => params[:group_ids]).order("start_time ASC")
    end
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
        json = "{\"events\" : [#{json}]"
        json += ",\n\"ref\" : \"#{params[:ref]}\"" if params[:ref]
        json += "}"
        
        render :json => json
      }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    redirect_to group_events_path(@event.group)+"#show#{@event.id}"
  end

  # POST /events
  # POST /events.xml
  # POST /events.json
  def create
    @group = Group.find(params[:event][:group_id])

    @event = Event.new(params[:event])
    @event.group = @group
    @event.attendees = User.where("andrewid" => params[:position_names]).uniq
    
    @events = Array.new
    @events.push @event
    
    respond_to do |format|
      if @event.save
        if params[:repeat]=="1"
          freq=params[:repeat_frequency].to_i
          per=params[:repeat_period].to_sym
          if params[:stop_condition_type] == "date"
            stop_on = Time.new(params["stop_on_time(1i)"],params["stop_on_time(2i)"],params["stop_on_time(3i)"],params["stop_on_time(4i)"],params["stop_on_time(5i)"])
            t=@event.start_time
            n=1
            while t<stop_on
              t=t.advance(per => freq)
              n=n+1
            end
          else
            n=params[:stop_after_occurrences].to_i
          end
          st=@event.start_time
          en=@event.end_time
          n=n-1
          n.times do
            st=st.advance(per => freq)
            en=en.advance(per => freq)
            e=@event.clone
            e.repeat_id=@event.id
            e.group_id=@event.group_id
            e.start_time=st
            e.end_time=en
            if e.save
              @events.push e
            else
              #TODO handle errors
            end
          end
        end
        create_feedpost
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
        format.json { render :json => {:errors => @event.errors } }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  # PUT /events/1.json
  def update
    respond_to do |format|
      old_event = @event.clone
      if @event.update_attributes(params[:event])
        @event.attendees = User.where("andrewid" => params[:position_names]).uniq
        unless params[:propagate].nil?
          #TODO better error handling: return errors instead of throwing exceptions
          # low priority because all propagations should at this point validate
          if params[:propagate]
            if @event.repeat_parent
              c = @event.repeat_parent.repeat_children.where(["start_time > ?",@event.start_time])
              c.each do |child|
                child.repeat_id = @event.id
                child.save!
              end
            end
            @event.repeat_id = nil
            @event.save!
            @event.propagate old_event
          else
            c = @event.repeat_children
            c.each do |child|
              child.repeat_id = c.first.id
              child.save!
            end
            @event.repeat_id = nil
            @event.save!
          end
        end
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
        format.json {
          json = "{\"group_id\":#{@event.group_id},\n\"event\":"+event_to_json(@event)
          json += ",\n\"ref\":\""+params[:ref]+"\"" if params[:ref]
          json += "}"
          render :json => json
        }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
        format.json {
          json = {:group_id => @event.group_id, :errors => @event.errors}
          json[:ref] = params[:ref] if params[:ref]
          render :json => json
        }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  # DELETE /events/1.json
  def destroy
    unless params[:propagate].nil?
      if params[:propagate]
        c = @event.repeat_parent.repeat_children.where(["start_time > ?",e.start_time])
        c.destroy_all
      else
        c = @event.repeat_children
        c.each do |child|
          child.repeat_id = c.first.id
          child.save!
        end
      end
    end
    event_id = @event.id
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(group_events_url(@event.group)) }
      format.xml  { head :ok }
      format.json {
        json = {:event_id => event_id}
        json[:ref] = params[:ref] if params[:ref]
        render :json => json
      }
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

  def create_feedpost
    f = Feedpost.new
    f.post_type = "create"
    f.user = current_user
    f.reference = @event
    f.parent = @event.group
    if @events.size > 1
      f.headline = "created events"
    else
      f.headline = "created an event"
    end
    f.body = @event.description
    f.save
  end
end
