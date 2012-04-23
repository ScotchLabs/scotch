class UsersController < ApplicationController

  prepend_before_filter :find_user

  before_filter :only => [:create, :destroy] do
    require_global_permission "adminUsers"
  end

  before_filter :only => [:edit, :update] do
    @user == current_user or require_global_permission "adminUsers"
  end

  # GET /users
  # GET /users.xml
  def index
    if params[:term]
      query = params[:term] + "%"
      @users = User.where(["first_name LIKE ? OR last_name LIKE ? OR email LIKE ?",query,query,query])
    else
      # @users = User.paginate(:per_page => 20, :page => params[:page])
      @users = []
      @new_users = User.newest
      @most_watched_users = User.most_watched
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => json_for_autocomplete(@users, :identifier) }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @years = @user.active_years("Show")
    
    respond_to do |format|
      format.html # show.html.erb

      if @user.public_profile? then
        format.xml  { render :xml => @user, :only => [:home_college, :gender,
          :id, :about, :majors, :other_activities, :andrewid, :minors,
          :birthday, :last_name, :first_name, :phone, :graduation_year, :smc,
          :email] }
      end
    end
  end

  # GET /users/1/edit
  def edit
    @user.valid?  # this makes the errors OrderedHash get some kv pairs.
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def find_user
   if params.has_key? :id
      if params[:id].to_i > 0
        @user = User.find(params[:id])
      else
        @user = User.find_by_andrewid!(params[:id])
      end
    end
  end

end
