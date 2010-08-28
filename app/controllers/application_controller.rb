class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'application'

  prepend_before_filter :locate_group
  prepend_before_filter :authenticate_user!

  protected

  def locate_group
    if params.has_key? :group_id then
      @group = Group.find(params[:group_id].to_i)
      params[:group_type] = @group.class.name unless params.has_key? :group_type
    end
  end

  def has_permission? (permName)
    permission = Permission.fetch(permName)

    if current_user.has_global_permission? permission then
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

end
