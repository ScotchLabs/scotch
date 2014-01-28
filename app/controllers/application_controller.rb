class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'application'

  prepend_before_filter :locate_group
  prepend_before_filter :locate_user
  prepend_before_filter :locate_item

  prepend_before_filter :authenticate_user!

  def encode_recipient(*args)
    args.join(':')
  end

  def decode_recipient(args)
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

  protected

  def locate_group
    if params.has_key? :group_id then
      @group = Group.find(params[:group_id].to_i)
    elsif params.has_key? :show_id then
      @group = Group.find(params[:show_id].to_i)
    elsif params.has_key? :board_id then
      @group = Group.find(params[:board_id].to_i)
    end
    params[:group_type] = @group.class.name unless params.has_key? :group_type
  end

  def locate_item
    if params.has_key? :item_id then
      @item = Item.find(params[:item_id].to_i)
    end
  end

  def locate_user
   if params.has_key? :user_id
      if params[:user_id].to_i > 0
        @user = User.find(params[:user_id])
      else
        @user = User.find_by_andrewid!(params[:user_id])
      end
    end
  end

  def has_permission? (permName)
    permission = Permission.fetch(permName)

    if current_user.has_global_permission? permission then
      return true
    end

    if @group.nil?
      return true
    end

    if @group.user_has_permission? current_user,permission
      return true
    end
  end

  def require_permission (permName)
    return true if has_permission?(permName)

    logger.warn "#{current_user} denied access due to lack of permission #{permName} for group #{@group || "-"}"

    flash[:notice] = "You are not authorized to do that!"

    redirect_to :dashboard_index
  end
  def require_global_permission (permName)
    permission = Permission.fetch(permName)

    if current_user.has_global_permission? permission then
      return true
    end

    logger.warn "#{current_user} denied access due to lack of permission #{permission}"

    flash[:notice] = "You are not authorized to do that!"

    redirect_to :dashboard_index
  end

  def json_for_autocomplete(items, method)
    items.collect do |item|
      {"id" => item.id.to_s, "label" => item.send(method), "value" => item.send(method)}
    end
  end

end
