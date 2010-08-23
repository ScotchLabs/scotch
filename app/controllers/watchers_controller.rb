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
    @watcher = Watcher.new(:item_type => params[:item_type], :item_id => params[:item_id], :user_id => current_user.id)

    respond_to do |format|
      if @watcher.save
        format.html { redirect_to(@watcher.item, :notice => "You are now following #{@watcher.item}.") }
        format.xml  { render :xml => @watcher }
      else
        format.html { redirect_to(@watcher.item, :notice => "Watcher could not be saved. #{@watcher.errors.inspect}") }
        format.xml  { render :xml => @watcher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /watchers/1
  # DELETE /watchers/1.xml
  def destroy
    @watcher = Watcher.find(params[:id])
    @item = @watcher.item
    puts "going to redirect to '#{@item}'"
    if @watcher.user == current_user
      @watcher.destroy
      flash[:notice] = "You are no longer following #{@item}."
    else
      flash[:notice] = "You can't delete that!"
    end

    respond_to do |format|
      format.html { redirect_to(@item) }
      format.xml  { head :ok }
    end
  end
end
