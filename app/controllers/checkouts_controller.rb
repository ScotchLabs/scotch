class CheckoutsController < ApplicationController
  
  before_filter :only => [:new, :create] do
    require_permission "checkoutSelf" unless has_permission? "checkoutOther"
  end

  # FIXME make sure that users don't try to checkout a not-available item....
  # before_filter :ensure_available, :only => [:new]

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

    logger.info "@checkout = #{@checkout.inspect}"

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
      @checkout.user = User.autocomplete_retreive_user(params[:user_identifier])
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

  # PUT /checkouts/1
  # PUT /checkouts/1.xml
  def update
    @checkout = Checkout.find(params[:id])
    @group = @checkout.group

    unless @checkout.open? and (has_permission? "checkoutOther" or (has_permission? "checkoutSelf" and @checkout.user == current_user))
      redirect_to(@checkout, :notice => "You do not have permission to update this checkout")
      return false
    end

    # FIXME we don't do any input validation here, so we are trusting that
    # authorized users can update this however they want...
    respond_to do |format|
      if @checkout.update_attributes(params[:checkout])
        format.html { redirect_to(@checkout, :notice => 'Checkout was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkout.errors, :status => :unprocessable_entity }
      end
    end
  end

end
