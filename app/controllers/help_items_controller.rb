class HelpItemsController < ApplicationController

  before_filter :only => [:edit, :update, :destroy] do 
    require_global_permission "adminHelpItems"
  end

  # GET /help_items
  # GET /help_items.xml
  def index
    @help_items = HelpItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @help_items }
    end
  end

  # GET /help_items/1
  # GET /help_items/1.xml
  def show
    @help_item = HelpItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @help_item }
    end
  end

  # GET /help_items/new
  # GET /help_items/new.xml
  def new
    redirect_to help_items_path, :notice => "Help items can not be added via the user interface.  Please contact a Scotch developer."
  end

  # GET /help_items/1/edit
  def edit
    @help_item = HelpItem.find(params[:id])
  end

  # PUT /help_items/1
  # PUT /help_items/1.xml
  def update
    @help_item = HelpItem.find(params[:id])

    respond_to do |format|
      if @help_item.update_attributes(params[:help_item])
        format.html { redirect_to(@help_item, :notice => 'Help item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @help_item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
