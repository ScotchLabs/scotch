class FeedpostsController < ApplicationController

  after_filter :send_user_notification, :only => :create
  after_filter :send_group_notification, :only => :create

  # FIXME:  specifically for shows, lets people with email permission force
  # emails out to relevant roles without regard to email permission
  # after_filter :send_show_notification, :only => :create

  # FIXME:  specifically for boards, notifies all with notify bit turned on
  # without regard to poster
  # after_filter :send_board_notification, :only => :create
  
  # FIXME:  send notification to those who want it and watch the item
  # after_filter :send_item_notification, :only => :create 
  
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

  protected

  # emails the user whose wall was written on
  def send_user_notification
    return true if @feedpost.new_record? ||
      params[:feedpost][:parent_type] != "User" ||
      @feedpost.parent.email_notifications == false ||
      params[:feedpost][:post_type] != "wall" ||
      @feedpost.parent == current_user

    FeedpostMailer.user_notification(@feedpost,@feedpost.parent).deliver
  end

  # specifically for groups, poster must have email permission, then
  # it goes to people who watch and want notification.
  def send_group_notification
    group = @feedpost.parent

    return true if @feedpost.new_record? ||
      params[:feedpost][:post_type] != "wall" ||
      group.class.name != "Group" ||
      not group.user_has_permission?(current_user, Permission.fetch("email"))

    group.watchers.each do |u|
      if u.email_notifications && u != current_user then
        FeedpostMailer.group_notification(@feedpost,u).deliver
      end
    end
  end
end
