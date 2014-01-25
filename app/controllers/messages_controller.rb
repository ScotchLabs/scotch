class MessagesController < ApplicationController
  before_filter :get_message, :except => [:new, :index, :create, :recipient_search]

  def index
    @messages = current_user.messages
  end

  def recipient_search
    @users = User.search(params[:query])
    @groups = Group.active

    @results = @users.map do |user|
      {name: user.name, value: encode_selection(user.id, 'User')}
    end

    @results += Role.all.map do |role|
      {name: role.name, value: encode_selection(role.id, 'Role')}
    end

    @groups.each do |group|
      @results << {name: "#{group.name} All", value: encode_selection(group.id, 'Group')}

      group.positions.uniq(&:role_id).each do |position|
        @results << {name: "#{group.name}: #{position.role.name}",
          value: encode_selection(position.role.id, group.id, 'Role')}
      end

      group.positions.uniq(&:display_name).each do |pos|
        @results << {name: "#{group.name}: #{pos.display_name}",
          value: encode_selection(pos.display_name, group.id, 'Position')}
      end
    end

    @results.select! {|x| x[:name].downcase.include?(params[:query].downcase)}

    respond_to do |format|
      format.json { render json: @results }
    end
  end

  def new
    @message = Message.new

    respond_to do |format|
      format.html do
        if params[:nolayout]
          @modal = true
          render 'modal', layout: false
        else
          render 'new'
        end
      end
    end
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])
    @message.sender = current_user

    respond_to do |format|
      if @message.save
        params[:message][:recipients_field].each do |recipient|
          unless recipient.empty?
            recipient = decode_selection(recipient)
            recipient.owner = @message
            recipient.save
          end
        end

        @message.deliver

        format.html { redirect_to @message, notice: 'Message was successfully sent.' }
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

  def get_message
    @message = Message.find(params[:id])
  end

  def encode_selection(*args)
    args.join(':')
  end

  def decode_selection(args)
    fields = args.split(':')
    id = fields[0]
    type = fields[-1]

    recipient = Recipient.new

    if fields.length == 2
      if type == 'User'
        recipient.target = User.find(id)
      elsif type == 'Role'
        recipient.target = Role.find(id)
      else
        recipient.target = Group.find(id)
      end
    elsif fields.length == 3
      recipient.group = Group.find(fields[1])

      if type == 'Position'
        recipient.target_identifier = id
        recipient.target_type = 'Position'
      else
        recipient.target = Role.find(id)
      end
    end

    recipient
  end
end
