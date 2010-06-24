class ItemSubcategoriesController < ApplicationController
  # GET /item_subcategories
  # GET /item_subcategories.xml
  def index
    @item_subcategories = ItemSubcategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @item_subcategories }
    end
  end

  # GET /item_subcategories/1
  # GET /item_subcategories/1.xml
  def show
    @item_subcategory = ItemSubcategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item_subcategory }
    end
  end

  # GET /item_subcategories/new
  # GET /item_subcategories/new.xml
  def new
    @item_subcategory = ItemSubcategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item_subcategory }
    end
  end

  # GET /item_subcategories/1/edit
  def edit
    @item_subcategory = ItemSubcategory.find(params[:id])
  end

  # POST /item_subcategories
  # POST /item_subcategories.xml
  def create
    @item_subcategory = ItemSubcategory.new(params[:item_subcategory])

    respond_to do |format|
      if @item_subcategory.save
        format.html { redirect_to(@item_subcategory, :notice => 'Item subcategory was successfully created.') }
        format.xml  { render :xml => @item_subcategory, :status => :created, :location => @item_subcategory }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item_subcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /item_subcategories/1
  # PUT /item_subcategories/1.xml
  def update
    @item_subcategory = ItemSubcategory.find(params[:id])

    respond_to do |format|
      if @item_subcategory.update_attributes(params[:item_subcategory])
        format.html { redirect_to(@item_subcategory, :notice => 'Item subcategory was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item_subcategory.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /item_subcategories/1
  # DELETE /item_subcategories/1.xml
  def destroy
    @item_subcategory = ItemSubcategory.find(params[:id])
    @item_subcategory.destroy

    respond_to do |format|
      format.html { redirect_to(item_subcategories_url) }
      format.xml  { head :ok }
    end
  end
end
