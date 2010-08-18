class FeedPostsController < ApplicationController
  # GET /feed_posts
  # GET /feed_posts.xml
  def index
    @feed_posts = FeedPost.all

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

  # GET /feed_posts/1/edit
  def edit
    @feed_post = FeedPost.find(params[:id])
  end

  # POST /feed_posts
  # POST /feed_posts.xml
  def create
    @feed_post = FeedPost.new(params[:feed_post])

    respond_to do |format|
      if @feed_post.save
        format.html { redirect_to(@feed_post, :notice => 'Feed post was successfully created.') }
        format.xml  { render :xml => @feed_post, :status => :created, :location => @feed_post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @feed_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feed_posts/1
  # PUT /feed_posts/1.xml
  def update
    @feed_post = FeedPost.find(params[:id])

    respond_to do |format|
      if @feed_post.update_attributes(params[:feed_post])
        format.html { redirect_to(@feed_post, :notice => 'Feed post was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feed_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feed_posts/1
  # DELETE /feed_posts/1.xml
  def destroy
    @feed_post = FeedPost.find(params[:id])
    @feed_post.destroy

    respond_to do |format|
      format.html { redirect_to(feed_posts_url) }
      format.xml  { head :ok }
    end
  end
end
