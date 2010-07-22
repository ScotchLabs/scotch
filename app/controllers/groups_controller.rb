class GroupsController < ApplicationController

  before_filter :only => [:new, :create] do
    require_permission Permission.fetch("createGroup")
  end

  # GET /groups
  # GET /groups.xml
  def index
    if params[:group_type] == "Show" then
      @groups = Show.all
    elsif params[:group_type] == "Board" then
      @groups = Board.all
    else
      @groups = Group.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    if params[:group_type] == "Show" then
      @group = Show.new
    else
      @group = Group.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    if params[:group_type] == "Show" then
      @group = Show.new(params[:show])
    elsif params[:group_type] == "Board" then
      @group = Board.new(params[:show])
    else
      @group = Group.new(params[:group])
    end

    user = User.find(params[:manager_id])
    role = @group.class.manager_role

    respond_to do |format|
      if @group.save 
        #FIXME: ensure this saves correctly
        @group.positions.create(:user => user, :role => role, :display_name => "Manager")

        format.html { redirect_to(@group, :notice => 'Group was successfully created.') }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to(@group, :notice => 'Group was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
