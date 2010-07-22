class DashboardController < ApplicationController
  def index
    unless current_user.valid?
      flash[:notice] = "Sorry, but we need you to fill out some profile information before continuing."
      redirect_to edit_user_path(current_user)
    end
  end

end
