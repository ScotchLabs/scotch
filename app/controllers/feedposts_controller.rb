class FeedpostsController < ApplicationController
  # GET /feedposts
  # GET /feedposts.xml
  def index
    #FIXME I don't know there's a polymorphic way to do this.
    if params[:checkout_id]
      @parent = Checkout.find(params[:checkout_id])
    elsif params[:document_id]
      @parent = Document.find(params[:document_id])
    elsif params[:event_id]
      @parent = Event.find(params[:event_id])
    elsif params[:feedpost_id]
      @parent = Feedpost.find(params[:feedpost_id])
    elsif params[:group_id]
      @parent = Group.find(params[:group_id])
    elsif params[:item_id]
      @parent = Item.find(params[:item_id])
    elsif params[:user_id]
      @parent = User.find_by_andrewid(params[:user_id])
    end
    
    if @parent.nil? or !@parent.respond_to? 'feedposts'
      @feedposts = Feedpost.all
    else
      @feedposts = @parent.feedposts
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedposts }
    end
  end

  # GET /feedposts/1
  # GET /feedposts/1.xml
  def show
    @feedpost = Feedpost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedpost }
    end
  end

  # GET /feedposts/new
  # GET /feedposts/new.xml
  def new
    @feedpost = Feedpost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedpost }
    end
  end

  # POST /feedposts
  # POST /feedposts.xml
  def create
    @feedpost = Feedpost.new(params[:feedpost])
    @feedpost.user_id = current_user.id
    @feedpost.parent_id = params[:feedpost][:parent_id]
    @feedpost.parent_type = params[:feedpost][:parent_type]

    respond_to do |format|
      if @feedpost.save
        format.html { redirect_to(url_for(@feedpost.parent), :notice => 'Feed post was successfully created.') }
        format.xml  { render :xml => @feedpost, :status => :created, :location => @feedpost }
      else
        format.html { redirect_to(url_for(@feedpost.parent), :notice => 'Feed post was NOT successfully created.') }
        format.xml  { render :xml => @feedpost.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedposts/1
  # DELETE /feedposts/1.xml
  def destroy
    @feedpost = Feedpost.find(params[:id])
    @parent = @feedpost.parent
    if @feedpost.user != current_user
      flash[:notice] = "You aren't allowed to destroy that post."
    else
      @feedpost.destroy
    end

    respond_to do |format|
      format.html { redirect_to(@parent) }
      format.xml  { head :ok }
    end
  end
end
