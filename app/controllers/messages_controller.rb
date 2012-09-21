class MessagesController < ApplicationController
  layout :get_layout
  before_filter :get_list
  before_filter :get_group
  before_filter :get_message, :except => [:new, :index, :create]

  def index
    @messages = @list ? @list.messages : []
  end

  def new
    @message = Message.new

    respond_to do |format|
      format.html
    end
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = @list.messages.new(params[:message])
    @message.sender = current_user

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url }
      format.json { head :no_content }
    end
  end
  
  protected

  def get_layout
    if @group
      'group'
    else
      'application'
    end
  end

  def get_group
    @group = @list.group if @list
  end

  def get_list
    @list = MessageList.find(params[:message_list_id]) if params[:message_list_id]
    @list = @message.message_list if @message && @message.message_list
  end
  
  def get_message
    @message = Message.find(params[:id])
  end
end
