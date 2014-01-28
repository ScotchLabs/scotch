class MessagesController < ApplicationController
  before_filter :get_message, :except => [:new, :index, :create, :recipient_search]

  def index
    @messages = current_user.messages
  end

  def recipient_search
    @users = User.search(params[:query])
    @groups = Group.active

    @results = @users.map do |user|
      {name: user.name, value: encode_recipient(user.id, 'User')}
    end

    @results += Role.all.map do |role|
      {name: role.name, value: encode_recipient(role.id, 'Role')}
    end

    @groups.each do |group|
      @results << {name: "#{group.name} All", value: encode_recipient(group.id, 'Group')}

      group.positions.uniq(&:role_id).each do |position|
        @results << {name: "#{group.name}: #{position.role.name}",
          value: encode_recipient(position.role.id, group.id, 'Role')}
      end

      group.positions.uniq(&:display_name).each do |pos|
        @results << {name: "#{group.name}: #{pos.display_name}",
          value: encode_recipient(pos.display_name, group.id, 'Position')}
      end

      group.message_lists.each do |list|
        @results << {name: "#{group.name}: #{list.name}",
          value: encode_recipient(list.id, group.id, 'MessageList')}
      end
    end

    @results.select! do |x|
      match = false

      params[:query].split(' ').each do |term|
        match = true if x[:name].downcase.include?(term.downcase)
      end

      match
    end

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
            recipient = decode_recipient(recipient)
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
end
