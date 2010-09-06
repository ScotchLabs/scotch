class DashboardController < ApplicationController
  def index
    unless current_user.valid?
      flash[:notice] = "Sorry, but we need you to fill out some profile information before continuing."
      redirect_to edit_user_path(current_user)
    end
  end

  def search
    @results = 
      User.with_query(params[:q]).limit(20) +
      Group.with_query(params[:q]).limit(20) +
      Item.with_query(params[:q]).limit(20) +
      Feedpost.with_query(params[:q]).limit(20)

    @results = @results.sort_by{|i| i.updated_at}
  end
end
