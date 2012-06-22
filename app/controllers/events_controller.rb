class EventsController < ApplicationController
  before_filter :get_owner, :only => [:index, :new, :create]
  before_filter :get_events, :only => [:index]
  before_filter :get_event, :except => [:index, :new, :create]
  
  def index
    
    respond_to do |format|
      format.html
    end
  end

  def show
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @event = @owner.events.new
    
    respond_to do |format|
      format.html
    end
  end

  def create
    @event = @owner.events.new(params[:event])
    
    respond_to do |format|
      if @event.save
        format.html {redirect_to @event}
        format.json {render json: @event}
      else
        format.html {redirect_to @parent}
        format.json {render json: @event, status: 218}
      end
    end
  end

  def edit
    
    respond_to do |format|
      format.html
    end
  end

  def update
    
    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html {redirect_to [@parent, @event].compact}
      else
        format.html {render action: 'edit'}
      end
    end
  end

  def destroy
    @parent = @event.owner
    @event.destroy
    
    respond_to do |format|
      format.html {redirect_to [@parent, :events]}
    end
  end
  
  protected
  
  def get_owner
    if params[:group_id]
      @owner = Group.find(params[:group_id])
      @parent = @owner
    else
      @owner = current_user
      @parent = nil
    end
  end
  
  def get_events
    @events = @owner.all_events
  end
  
  def get_event
    @event = Event.find(params[:id])
    @owner = @event.owner
    @parent = @event.owner.class == 'User' ? nil : @owner
  end

end
