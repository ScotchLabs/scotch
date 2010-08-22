class CheckoutEventsController < ApplicationController
  def new
    @checkout_event = CheckoutEvent.new
    @checkout_event.checkout_id = params[:checkout_id]
    @checkout_event.event = params[:event]
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @checkout_event = CheckoutEvent.new(params[:checkout_event])
    @checkout_event.user_id = current_user.id
    @checkout = @checkout_event.checkout
    
    respond_to do |format|
      if @checkout_event.save
        format.html { redirect_to(@checkout, :notice => "Event was successfully saved.") }
      else
        format.html { render :action => "new" }
      end
    end
  end
end
