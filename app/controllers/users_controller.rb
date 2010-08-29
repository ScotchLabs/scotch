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
    # Autocomplete uses the q param and the js format
    # FIXME this loads all users from the database, ouch!
    if params[:q]
      @users = User.all.select {|u| u.name.downcase.include?(params[:q].downcase) or u.email.downcase.include?(params[:q].downcase)}
    else
      @users = User.paginate(:per_page => 20, :page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.js { render :text => @users.map{|u| "#{u.name} #{u.email}"}.join("\n") }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb

      # FIXME: this leaks information
      format.xml  { render :xml => @user }
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
    unless params.nil? or params[:id].nil? or params[:id].to_i > 0
      @user = User.find_by_andrewid(params[:id])
      raise ActiveRecord::RecordNotFound unless @user
    end
  end
end
