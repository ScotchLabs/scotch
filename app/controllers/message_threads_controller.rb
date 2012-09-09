class MessageThreadsController < ApplicationController
  before_filter :get_threads, :only => [:index]
  before_filter :get_thread, :except => [:index, :new, :create]
  
  before_filter :only => [:new, :create, :destroy] do
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

    if @thread.reply_type == 'self'
      @messages = [@thread.messages.first] + @thread.messages.where('user_id = ? OR target_id = ?', current_user, current_user)
      @messages.uniq!
    else @thread.reply_type == 'all'
      @messages = @thread.messages
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @thread }
    end
  end

  # GET /message_threads/new
  # GET /message_threads/new.json
  def new
    @thread = MessageThread.new

    if params[:recipients]
      @prepop = params[:recipients].split(',').map do |r|
        u = User.find_by_andrewid(r)
        if u
          {id: u.id, name: u.name}
        else
          nil
        end
      end.compact
    end

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
    @thread = @group.message_threads.new(params[:message_thread])
    @thread.first_message_sender = current_user

    respond_to do |format|
      if @thread.save
        format.html { redirect_to @thread, notice: 'Message thread was successfully created.' }
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
    @thread.update_attribute(:deleted, true)

    respond_to do |format|
      format.html { redirect_to group_message_threads_url(@group) }
      format.json { head :no_content }
    end
  end
  
  protected
  
  def get_threads
    @threads = @group ? MessageThread.visible(current_user, @group) : MessageThread.visible(current_user)
  end
  
  def get_thread
    @thread = MessageThread.find(params[:id])
    @group ||= @thread.group
  end
  
  def get_layout
    if @group
      'group'
    else
      'application'
    end
  end
end
