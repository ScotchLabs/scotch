class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new    
  end
  
  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.email = current_user.email
    if @feedback.valid?
      FeedbackMailer.deliver_feedback(@feedback)
      flash[:notice] = "Thank you for your feedback!"
      redirect_to dashboard_index_path
    else
      @error_message = "Please enter your #{@feedback.subject.to_s.downcase}"
      render :action => 'new', :status => :unprocessable_entity
    end
  end
end
