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
    @oldparity = nil
    
    if @knomination.kudo.voting_open? #I know, the code is disgusting, it's temporary.
      if !@knomination.nil? && @knomination.kaward.kvotes.exists?(:user_id => current_user.id, :stage => 'vote')
        @vote = @knomination.kaward.kvotes.where(:user_id => current_user.id, :stage => 'vote').first
        @vote.destroy
        @vote = nil
      end
      @vote = @knomination.kvotes.create(:user_id => current_user.id, :stage => 'vote')
      
    elsif @knomination.kudo.nominations_open?
      if !@knomination.nil? && @knomination.kvotes.exists?(:user_id => current_user.id, :stage => nil)
        @vote = @knomination.kvotes.where(:user_id => current_user.id, :stage => nil).first
        @oldparity = @vote.positive
        @vote.destroy
        @vote = nil
      end
    
      if params[:parity] == "1"
        if @oldparity.nil? || !@oldparity
          @vote = @knomination.kvotes.create(:user_id => current_user.id, :positive => true, :stage => nil)
        end
      elsif params[:parity] == "0"
        if @oldparity.nil? || @oldparity
          @vote = @knomination.kvotes.create(:user_id => current_user.id, :positive => false, :stage => nil)
        end
      end
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
        format.html { redirect_to Kudo.find(params[:kudo_id]) }
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
    @knomination.deleted = true
    @knomination.save

    respond_to do |format|
      format.html {head :ok}
      format.js
      format.xml  { head :ok }
    end
  end
end
