class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'application'

  before_filter :authenticate_user!

  before_filter :locate_group

  protected

  def locate_group
    if params.has_key? :group_id then
      @group = Group.find(params[:group_id].to_i)
    end
  end
end
