include ApplicationHelper

class CheckoutsController < ApplicationController
  # GET /group/1/checkouts
  # GET /group/1/checkouts.xml
  def index
    @checkouts = Checkout.all
    @item = Item.find(params[:item_id]) if params[:item_id]
    @group = Group.find(params[:group_id]) if params[:group_id]

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
    @checkout.user_id = current_user.id
    @items = Item.all.sort unless params[:item_id]
    @groups = Group.all unless params[:group_id]
    @users = User.all
    if params[:group_id]
      group = Group.find params[:group_id]
    elsif params[:item_id]
      item = Item.find params[:item_id]
    end
    @checkout.group = group
    @group = @checkout.group
    @checkout.item = item
    @item = @checkout.item

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checkout }
    end
  end

  # GET /checkouts/1/edit
  #def edit
  #  @checkout = Checkout.find(params[:id])
  #  @items = Item.all.sort unless params[:item_id]
  #  @groups = Group.all unless params[:group_id]
  #  @users = User.all
  #end

  # POST /checkouts
  # POST /checkouts.xml
  def create
    @checkout = Checkout.new(params[:checkout])
    @checkout.opener_id = current_user.id
    @item = Item.find(@checkout.item_id)
    @items = Item.all.sort unless params[:item_id]
    @group = Group.find(params[:checkout][:group_id])
    @groups = Group.all unless params[:group_id]
    u = retreive_user(params[:custom][:user_identifier])
    @checkout.user_id = u.id

    respond_to do |format|
      begin
        if @checkout.save
          format.html { redirect_to(@checkout, :notice => 'Checkout was successfully created.') }
          format.xml  { render :xml => @checkout, :status => :created, :location => @checkout }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @checkout.errors, :status => :unprocessable_entity }
        end
      rescue Exception => e
        flash[:notice] = e.message
      end
    end
  end

  # PUT /checkouts/1
  # PUT /checkouts/1.xml
  #def update
  #  @checkout = Checkout.find(params[:id])
  #
  #  respond_to do |format|
  #    if @checkout.update_attributes(params[:checkout])
  #      format.html { redirect_to(@checkout, :notice => 'Checkout was successfully updated.') }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @checkout.errors, :status => :unprocessable_entity }
  #    end
  #  end
  #end

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
