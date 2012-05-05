class KudosController < ApplicationController
  before_filter :only => [:new, :create, :edit, :update, :destroy] do
    require_permission "adminElection"
  end
  
  # GET /kudos
  # GET /kudos.xml
  def index
    @kudos = Kudo.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @kudos }
    end
  end

  # GET /kudos/1
  # GET /kudos/1.xml
  def show
    @kudo = Kudo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @kudo }
    end
  end

  # GET /kudos/new
  # GET /kudos/new.xml
  def new
    @kudo = Kudo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @kudo }
    end
  end

  # GET /kudos/1/edit
  def edit
    @kudo = Kudo.find(params[:id])
  end

  # POST /kudos
  # POST /kudos.xml
  def create
    @kudo = Kudo.new(params[:kudo])

    respond_to do |format|
      if @kudo.save
        format.html { redirect_to(@kudo, :notice => 'Kudos was successfully created.') }
        format.xml  { render :xml => @kudo, :status => :created, :location => @kudo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @kudo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /kudos/1
  # PUT /kudos/1.xml
  def update
    @kudo = Kudo.find(params[:id])

    respond_to do |format|
      if @kudo.update_attributes(params[:kudo])
        format.html { redirect_to(@kudo, :notice => 'Kudos was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @kudo.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /kudos/1
  # DELETE /kudos/1.xml
  def destroy
    @kudo = Kudo.find(params[:id])
    #@kudo.destroy

    respond_to do |format|
      format.html { redirect_to(kudos_index_url) }
      format.xml  { head :ok }
    end
  end
end
