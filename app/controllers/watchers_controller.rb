class WatchersController < ApplicationController
  # GET /watchers
  # GET /watchers.xml
  def index
    @watchers = Watcher.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @watchers }
    end
  end

  # GET /watchers/1
  # GET /watchers/1.xml
  def show
    @watcher = Watcher.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @watcher }
    end
  end

  # GET /watchers/new
  # GET /watchers/new.xml
  def new
    @watcher = Watcher.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @watcher }
    end
  end

  # GET /watchers/1/edit
  def edit
    @watcher = Watcher.find(params[:id])
  end

  # POST /watchers
  # POST /watchers.xml
  def create
    @watcher = Watcher.new(params[:watcher])

    respond_to do |format|
      if @watcher.save
        format.html { redirect_to(@watcher, :notice => 'Watcher was successfully created.') }
        format.xml  { render :xml => @watcher, :status => :created, :location => @watcher }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @watcher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /watchers/1
  # PUT /watchers/1.xml
  def update
    @watcher = Watcher.find(params[:id])

    respond_to do |format|
      if @watcher.update_attributes(params[:watcher])
        format.html { redirect_to(@watcher, :notice => 'Watcher was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @watcher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /watchers/1
  # DELETE /watchers/1.xml
  def destroy
    @watcher = Watcher.find(params[:id])
    @watcher.destroy

    respond_to do |format|
      format.html { redirect_to(watchers_url) }
      format.xml  { head :ok }
    end
  end
end
