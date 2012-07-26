class MessageThreadsController < ApplicationController
  before_filter :get_owner, :only => [:index, :new, :create]
  before_filter :get_threads, :only => [:index]
  before_filter :get_thread, :except => [:index, :new, :create]
  
  before_filter :only => [:new, :create] do
    require_permission "adminGroup"
  end
  
  layout :get_layout
  
  # GET /message_threads
  # GET /message_threads.json
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @threads }
    end
  end

  # GET /message_threads/1
  # GET /message_threads/1.json
  def show
    @nomargin = true

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @thread }
    end
  end

  # GET /message_threads/new
  # GET /message_threads/new.json
  def new
    @thread = MessageThread.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @thread }
    end
  end

  # GET /message_threads/1/edit
  def edit
    
  end

  # POST /message_threads
  # POST /message_threads.json
  def create
    @thread = MessageThread.new(params[:message_thread])

    respond_to do |format|
      if @thread.save
        format.html { redirect_to [@parent, @thread].compact, notice: 'Message thread was successfully created.' }
        format.json { render json: @thread, status: :created, location: @thread }
      else
        format.html { render action: "new" }
        format.json { render json: @thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /message_threads/1
  # PUT /message_threads/1.json
  def update

    respond_to do |format|
      if @thread.update_attributes(params[:message_thread])
        format.html { redirect_to @thread, notice: 'Message thread was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @thread.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /message_threads/1
  # DELETE /message_threads/1.json
  def destroy
    
    @thread.destroy

    respond_to do |format|
      format.html { redirect_to message_threads_url }
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
    @threads = @group ? MessageThread.visible(current_user, @owner) : MessageThread.visible(current_user)
  end
  
  def get_thread
    @thread = MessageThread.find(params[:id])
    @owner = @thread.group ? @thread.group : current_user
    @parent = @owner.class == 'User' ? nil : @owner
    @group = @parent if @parent
  end
  
  def get_layout
    if @group
      'group'
    else
      'application'
    end
  end
end
