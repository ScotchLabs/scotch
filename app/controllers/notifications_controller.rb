class NotificationsController < ApplicationController
  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = current_user.notifications

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notifications }
    end
  end
  
  def read
    current_user.notifications.unread.update_all(read: true)
    
    respond_to do |format|
      format.js
    end
  end
end
