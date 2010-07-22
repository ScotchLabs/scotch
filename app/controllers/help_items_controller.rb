class HelpItemsController < ApplicationController
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
    @help_item = HelpItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @help_item }
    end
  end

  # GET /help_items/1/edit
  def edit
    @help_item = HelpItem.find(params[:id])
  end

  # POST /help_items
  # POST /help_items.xml
  def create
    @help_item = HelpItem.new(params[:help_item])

    respond_to do |format|
      if @help_item.save
        format.html { redirect_to(@help_item, :notice => 'Help item was successfully created.') }
        format.xml  { render :xml => @help_item, :status => :created, :location => @help_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @help_item.errors, :status => :unprocessable_entity }
      end
    end
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

  # DELETE /help_items/1
  # DELETE /help_items/1.xml
  def destroy
    @help_item = HelpItem.find(params[:id])
    @help_item.destroy

    respond_to do |format|
      format.html { redirect_to(help_items_url) }
      format.xml  { head :ok }
    end
  end
end
