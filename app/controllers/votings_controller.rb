class VotingsController < ApplicationController
  # GET /votings
  # GET /votings.xml
  def index
    @votings = Voting.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @votings }
    end
  end

  # GET /votings/1
  # GET /votings/1.xml
  def show
    @voting = Voting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voting }
    end
  end

  # GET /votings/new
  # GET /votings/new.xml
  def new
    @voting = Voting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @voting }
    end
  end

  # GET /votings/1/edit
  def edit
    @voting = Voting.find(params[:id])
  end

  # POST /votings
  # POST /votings.xml
  def create
    @voting = Voting.new(params[:voting])

    respond_to do |format|
      if @voting.save
        format.html { redirect_to(@voting, :notice => 'Voting was successfully created.') }
        format.xml  { render :xml => @voting, :status => :created, :location => @voting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @voting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /votings/1
  # PUT /votings/1.xml
  def update
    @voting = Voting.find(params[:id])

    respond_to do |format|
      if @voting.update_attributes(params[:voting])
        format.html { redirect_to(@voting, :notice => 'Voting was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /votings/1
  # DELETE /votings/1.xml
  def destroy
    @voting = Voting.find(params[:id])
    @voting.destroy

    respond_to do |format|
      format.html { redirect_to(votings_url) }
      format.xml  { head :ok }
    end
  end
end
