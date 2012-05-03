class KnominationsController < ApplicationController
  before_filter :only => [:new, :edit, :update, :destroy] do
    require_permission "adminElection"
  end
  
  # GET /knominations
  # GET /knominations.xml
  def index
    @knominations = Knomination.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @knominations }
    end
  end

  # GET /knominations/1
  # GET /knominations/1.xml
  def show
    @knomination = Knomination.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @knomination }
    end
  end
  
  def vote
    @knomination = Knomination.find(params[:id])
    if !@knomination.nil? && @knomination.kvotes.exists?(:user_id => current_user.id)
      @vote = @knomination.kvotes.where(:user_id => current_user.id).first
      @knomination.kvotes.delete(@vote) #I know this is leavin residue, it's a quickfix
    end
    
    if params[:parity] == "1"
      @vote = @knomination.kvotes.create(:user_id => current_user.id, :positive => true)
    elsif params[:parity] == "0"
      @vote = @knomination.kvotes.create(:user_id => current_user.id, :positive => false)
    end
    
    respond_to do |format|
      format.js
    end
  end

  # GET /knominations/new
  # GET /knominations/new.xml
  def new
    @knomination = Knomination.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @knomination }
    end
  end

  # GET /knominations/1/edit
  def edit
    @knomination = Knomination.find(params[:id])
  end

  # POST /knominations
  # POST /knominations.xml
  def create
    @knomination = Kaward.find(params[:kaward_id]).knominations.create(params[:knomination])

    respond_to do |format|
      if @knomination.save
        format.html { redirect_to(@knomination.kudo, :notice => 'Knomination was successfully created.') }
        format.xml  { render :xml => @knomination, :status => :created, :location => @knomination }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @knomination.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /knominations/1
  # PUT /knominations/1.xml
  def update
    @knomination = Knomination.find(params[:id])

    respond_to do |format|
      if @knomination.update_attributes(params[:knomination])
        format.html { redirect_to(@knomination, :notice => 'Knomination was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @knomination.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /knominations/1
  # DELETE /knominations/1.xml
  def destroy
    @knomination = Knomination.find(params[:id])
    @knomination.destroy

    respond_to do |format|
      format.html { redirect_to(knominations_url) }
      format.xml  { head :ok }
    end
  end
end
