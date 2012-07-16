class ThreadsController < ApplicationController
  layout :get_layout
  before_filter :get_owner, :only => [:index, :new, :create]
  before_filter :get_threads, :only => [:index]
  before_filter :get_thread, :except => [:index, :new, :create]
  
  # GET /threads
  # GET /threads.json
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @threads }
    end
  end

  # GET /threads/1
  # GET /threads/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @thread }
    end
  end

  # GET /threads/new
  # GET /threads/new.json
  def new
    @thread = MessageThread.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @thread }
    end
  end

  # GET /threads/1/edit
  def edit
    
  end

  # POST /threads
  # POST /threads.json
  def create
    @thread = MessageThread.new(params[:thread])

    respond_to do |format|
      if @thread.save
        format.html { redirect_to @thread, notice: 'Thread was successfully created.' }
        format.json { render json: @thread, status: :created, location: @thread }
      else
        format.html { render action: "new" }
        format.json { render json: @thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /threads/1
  # PUT /threads/1.json
  def update

    respond_to do |format|
      if @thread.update_attributes(params[:thread])
        format.html { redirect_to @thread, notice: 'Thread was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /threads/1
  # DELETE /threads/1.json
  def destroy
    @thread.destroy

    respond_to do |format|
      format.html { redirect_to threads_url }
      format.json { head :no_content }
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
  
  def get_threads
    @threads = @owner.message_threads
  end
  
  def get_thread
    @thread = MessageThread.find(params[:id])
    @owner = @event.group ? @event.group : current_user
    @parent = @owner.class == 'User' ? nil : @owner
  end
  
  def get_layout
    if params[:group_id]
      'group'
    else
      'application'
    end
  end
  
end
