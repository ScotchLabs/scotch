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

  def edit
    @checkout_event = CheckoutEvent.find(params[:id])
  end

  def update
    @checkout_event = CheckoutEvent.find(params[:id])
    @checkout_event.user_id = current_user.id
    
    respond_to do |format|
      if @checkout_event.update_attributes(params[:checkout_event])
        format.html { redirect_to @checkout_event.checkout, :notice => "Event was successfully updated." }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @checkout_event = CheckoutEvent.find(params[:id])
    @checkout =  @checkout_event.checkout
    @checkout_event.destroy

    respond_to do |format|
      format.html { redirect_to @checkout }
      format.xml  { head :ok }
    end
  end

end
