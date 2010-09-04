class CheckoutsController < ApplicationController
  
  before_filter :only => [:new, :create] do
    require_permission "checkoutSelf" unless has_permission? "checkoutOther"
  end

  # GET /group/1/checkouts
  # GET /group/1/checkouts.xml
  def index
    #FIXME this shouldn't display all.  Instead, it should only display
    # outstanding checkouts.  This may mean adding a boolean "outstanding"
    # field to the checkouts object so that we can quickly query for it, or
    # some fancy sql magic involving multiple joins of the same table.
    @checkouts = Checkout.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checkouts }
    end
  end

  # GET /checkouts/1
  # GET /checkouts/1.xml
  def show
    @checkout = Checkout.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @checkout }
    end
  end

  # GET /checkouts/new
  # GET /checkouts/new.xml
  def new
    @checkout = Checkout.new

    @checkout.user = current_user
    @checkout.group = @group if @group
    @checkout.item = @item if @item

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checkout }
    end
  end

  # POST /checkouts
  # POST /checkouts.xml
  def create
    @checkout = Checkout.new(params[:checkout])
    @checkout.opener_id = current_user.id

    # set some things for the error view
    @item = @checkout.item
    @group = @checkout.group # must do this prior to permission checks

    # If the user can't checkout as that group, set it to nil to cause an
    # error FIXME this should be done better so that we see a more helpful
    # error message
    @checkout.group = nil unless has_permission?("checkoutSelf") or has_permission?("checkoutOther")

    if has_permission? "checkoutOther"
      @checkout.user = User.autocomplete_retreive_user(params[:custom][:user_identifier])
    else
      @checkout.user = current_user
    end

    respond_to do |format|
      if @checkout.save
        format.html { redirect_to(@checkout, :notice => 'Checkout was successfully created.') }
        format.xml  { render :xml => @checkout, :status => :created, :location => @checkout }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @checkout.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkouts/1
  # DELETE /checkouts/1.xml
  def destroy
    @checkout = Checkout.find(params[:id])
    @checkout.destroy

    respond_to do |format|
      format.html { redirect_to(checkouts_url) }
      format.xml  { head :ok }
    end
  end
end
