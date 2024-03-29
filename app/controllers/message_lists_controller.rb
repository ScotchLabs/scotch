class MessageListsController < ApplicationController
  layout 'group'

  before_filter :get_lists, only: [:index]
  before_filter :get_list, except: [:index, :new, :create]
  before_filter :get_group, except: [:index, :new, :create, :mass_add]

  before_filter :except => [:index, :show] do
    require_permission "adminCrew"
  end

  # GET /message_lists
  # GET /message_lists.json
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @message_lists }
    end
  end

  # GET /message_lists/1
  # GET /message_lists/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message_list }
    end
  end

  # GET /message_lists/new
  # GET /message_lists/new.json
  def new
    @list = [@group, MessageList.new]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list }
    end
  end

  # GET /message_lists/1/edit
  def edit
    @list = @message_list
  end

  # POST /message_lists
  # POST /message_lists.json
  def create
    @message_list = @group.message_lists.new(params[:message_list])

    respond_to do |format|
      if @message_list.save
        params[:message_list][:recipients_field].each do |recipient|
          unless recipient.empty?
            recipient = decode_recipient(recipient)
            recipient.owner = @message_list
            recipient.save
          end
        end

        format.html { redirect_to @message_list, notice: 'Message list was successfully created.' }
        format.json { render json: @message_list, status: :created, location: @message_list }
      else
        format.html { render action: "new" }
        format.json { render json: @message_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /message_lists/1
  # PUT /message_lists/1.json
  def update

    respond_to do |format|
      if @message_list.update_attributes(params[:message_list])
        params[:message_list][:recipients_field].each do |recipient|
          unless recipient.empty?
            recipient = decode_recipient(recipient)
            recipient.owner = @message_list
            recipient.save
          end
        end

        format.html { redirect_to @message_list, notice: 'Message list was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def mass_add
    params[:emails].split(',').each do |email|
      contact = Contact.where(protocol: 'email', address: email.strip).first_or_create

      @message_list.recipients.create(target: contact)
    end

    respond_to do |format|
      format.html { redirect_to @message_list, notice: 'Emails Added.' }
    end
  end

  # DELETE /message_lists/1
  # DELETE /message_lists/1.json
  def destroy
    @message_list.destroy

    respond_to do |format|
      format.html { redirect_to group_message_lists_url(@group) }
      format.json { head :no_content }
    end
  end

  protected

  def get_group
    @group = @message_list.group
  end

  def get_lists
    @message_lists = @group.message_lists
  end

  def get_list
    @message_list = MessageList.find(params[:id])
  end
end
