class FeedpostsController < ApplicationController

  after_filter :send_user_notification, :only => :create
  after_filter :send_group_notification, :only => :create
  after_filter :send_board_notification, :only => :create
  after_filter :send_show_notification, :only => :create
  
  # GET /feedposts
  # GET /feedposts.xml
  def index
    @parent = (@group or @user or @item)
    
    if @parent.nil? or !@parent.respond_to? 'feedposts'
      @feedposts = []
    else
      @feedposts = @parent.feedposts
    end
    
    @feedposts = @feedposts.paginate(:per_page => 30, :page => params[:page])

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
      format.html {
        if params[:ajax]
          render :html => @feedpost, :layout => false
        else
          render :html => @feedpost
        end
      }# show.html.erb
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
    @feedpost.document_id = params[:document_id] if params[:document_id]

    respond_to do |format|
      if @feedpost.save
        parent = @feedpost.parent
        
        unless params[:ajax]
          format.html { redirect_to(url_for(parent), :notice => 'Post was successfully created.') }
          format.xml  { render :xml => @feedpost, :status => :created, :location => @feedpost }
        else
          redirect = @feedpost
          redirect = @feedpost.parent if @feedpost.parent_type == "Feedpost"          
          format.html { redirect_to(url_for(:action => :show, :id => redirect.id, :ajax => true)) }
        end
      else
        debugger
        unless params[:ajax]
          format.html { redirect_to(url_for(parent), :notice => 'Post was NOT successfully created.') }
          format.xml  { render :xml => @feedpost.errors, :status => :unprocessable_entity }
        else
          raise "Post not successfully created"
        end
      end
    end
  end

  # DELETE /feedposts/1
  # DELETE /feedposts/1.xml
  def destroy
    @feedpost = Feedpost.find(params[:id])
    @parent = @feedpost.parent

    # FIXME this should be moved to a before_filter
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
  
  #Pass an id and post_id to this action to update a wall with more posts after that post_id.
  def more
    @feedposts = Feedpost.recent.after(params[:id], params[:type], params[:post_id])
    
    respond_to do |format|
      format.js
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

  # FIXME DRY group and board notifications, since they are so similar.
  # Really, this notification code could all stand a refactor

  # specifically for groups, poster must have email permission, then
  # it goes to people who watch and want notification.
  def send_group_notification
    @group = @feedpost.parent

    return true if @feedpost.new_record? || params[:email] != "email" ||
      params[:feedpost][:post_type] != "wall" ||
      @group.class.name != "Group" ||
      (! has_permission?("email"))

    emails = @group.watchers.collect{|w| w.user}.select{|u| u.email_notifications}.collect{|u| u.email}

    FeedpostMailer.group_notification(@feedpost,emails).deliver
  end

  # specifically for boards, notifies all with notify bit turned on
  # when poster is in board
  def send_board_notification
    @group = @feedpost.parent

    return true if @feedpost.new_record? || params[:email] != "email" ||
      params[:feedpost][:post_type] != "wall" ||
      @group.class.name != "Board" ||
      (! @group.users.include? current_user)

    emails = @group.watchers.collect{|w| w.user}.select{|u| u.email_notifications}.collect{|u| u.email}

    FeedpostMailer.group_notification(@feedpost,emails).deliver
  end

  # specifically for shows, lets people with email permission force
  # emails out to relevant roles without regard to email permission
  def send_show_notification
    @group = @feedpost.parent

    return true if @feedpost.new_record? ||
      params[:feedpost][:post_type] != "wall" ||
      @group.class.name != "Show" ||
      (! has_permission?("email"))

    users = User.where(:andrewid => params[:email_names]).uniq

    @feedpost.recipient_ids = users.collect{|u| u.id}
    @feedpost.save!

    emails = users.collect{|u| u.email}

    logger.info "sending show notification to #{emails.inspect}"

    FeedpostMailer.group_notification(@feedpost,emails).deliver unless emails.empty?
  end
end
