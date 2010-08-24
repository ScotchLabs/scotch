class FeedPostsController < ApplicationController
  # GET /feed_posts
  # GET /feed_posts.xml
  def index
    #FIXME I don't know there's a polymorphic way to do this.
    if params[:checkout_id]
      @parent = Checkout.find(params[:checkout_id])
    elsif params[:document_id]
      @parent = Document.find(params[:document_id])
    elsif params[:event_id]
      @parent = Event.find(params[:event_id])
    elsif params[:feed_post_id]
      @parent = FeedPost.find(params[:feed_post_id])
    elsif params[:group_id]
      @parent = Group.find(params[:group_id])
    elsif params[:item_id]
      @parent = Item.find(params[:item_id])
    elsif params[:user_id]
      @parent = User.find_by_andrew_id(params[:user_id])
    end
    
    if @parent.nil? or !@parent.respond_to? 'feed_posts'
      @feed_posts = FeedPost.all
    else
      @feed_posts = @parent.feed_posts
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feed_posts }
    end
  end

  # GET /feed_posts/1
  # GET /feed_posts/1.xml
  def show
    @feed_post = FeedPost.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feed_post }
    end
  end

  # GET /feed_posts/new
  # GET /feed_posts/new.xml
  def new
    @feed_post = FeedPost.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feed_post }
    end
  end

  # POST /feed_posts
  # POST /feed_posts.xml
  def create
    @feed_post = FeedPost.new(params[:feed_post])
    @feed_post.user_id = current_user.id

    respond_to do |format|
      if @feed_post.save
        format.html { redirect_to(url_for(@feed_post.parent), :notice => 'Feed post was successfully created.') }
        format.xml  { render :xml => @feed_post, :status => :created, :location => @feed_post }
      else
        format.html { render url_for @feed_post.parent }
        format.xml  { render :xml => @feed_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feed_posts/1
  # DELETE /feed_posts/1.xml
  def destroy
    @feed_post = FeedPost.find(params[:id])
    @parent = @feed_post.parent
    if @feed_post.user != current_user
      flash[:notice] = "You aren't allowed to destroy that post."
    else
      @feed_post.destroy
    end

    respond_to do |format|
      format.html { redirect_to(@parent) }
      format.xml  { head :ok }
    end
  end
end
