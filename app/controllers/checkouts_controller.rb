class CheckoutsController < ApplicationController
  
  # POST /checkouts
  # POST /checkouts.xml
  def create
    @checkout = Checkout.new(params[:checkout])
    @checkout.user = current_user

    respond_to do |format|
      if @checkout.save
        format.html { redirect_to(@checkout.item, :notice => 'Checkout was successfully created.') }
        format.xml  { render :xml => @checkout, :status => :created, :location => @checkout }
      else
        # set some things for the error view
        @item = @checkout.item

        format.html { render :action => "new" }
        format.xml  { render :xml => @checkout.errors, :status => :unprocessable_entity }
      end
    end
  end

  # This closes the checkout.
  # PUT /checkouts/1
  # PUT /checkouts/1.xml
  def update
    @checkout = Checkout.find(params[:id])
    @checkout.checkin_date = Date.today
    @checkout.notes = @checkout.notes + "\n-----\n" + params[:additional_notes]

    # FIXME we don't do any input validation here
    respond_to do |format|
      if @checkout.save
        format.html { redirect_to(@checkout.item, :notice => 'Checkout was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkout.errors, :status => :unprocessable_entity }
      end
    end
  end

end
