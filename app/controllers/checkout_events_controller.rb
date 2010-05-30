class CheckoutEventsController < ApplicationController
  # GET /checkout_events
  # GET /checkout_events.xml
  def index
    @checkout_events = CheckoutEvent.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checkout_events }
    end
  end

  # GET /checkout_events/1
  # GET /checkout_events/1.xml
  def show
    @checkout_event = CheckoutEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @checkout_event }
    end
  end

  # GET /checkout_events/new
  # GET /checkout_events/new.xml
  def new
    @checkout_event = CheckoutEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checkout_event }
    end
  end

  # GET /checkout_events/1/edit
  def edit
    @checkout_event = CheckoutEvent.find(params[:id])
  end

  # POST /checkout_events
  # POST /checkout_events.xml
  def create
    @checkout_event = CheckoutEvent.new(params[:checkout_event])

    respond_to do |format|
      if @checkout_event.save
        format.html { redirect_to(@checkout_event, :notice => 'Checkout event was successfully created.') }
        format.xml  { render :xml => @checkout_event, :status => :created, :location => @checkout_event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @checkout_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_events/1
  # PUT /checkout_events/1.xml
  def update
    @checkout_event = CheckoutEvent.find(params[:id])

    respond_to do |format|
      if @checkout_event.update_attributes(params[:checkout_event])
        format.html { redirect_to(@checkout_event, :notice => 'Checkout event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkout_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_events/1
  # DELETE /checkout_events/1.xml
  def destroy
    @checkout_event = CheckoutEvent.find(params[:id])
    @checkout_event.destroy

    respond_to do |format|
      format.html { redirect_to(checkout_events_url) }
      format.xml  { head :ok }
    end
  end
end
