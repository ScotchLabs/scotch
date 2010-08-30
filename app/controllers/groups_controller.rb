class GroupsController < ApplicationController

  before_filter :only => [:new, :create] do
    if params[:group_type] == "Show" then
      require_global_permission "createShow"
    elsif params[:group_type] == "Board" then
      require_global_permission "createBoard"
    else
      require_global_permission "createGroup"
    end
  end

  append_before_filter :only => [:signup, :leave] do
    if @group.class.name != "Group" then
      flash[:notice] = "You can not signup or leave a non-group"
      redirect_to (@group or groups_url)
    end
  end

  prepend_before_filter :locate_our_group, :only => [:show, :edit, :update, :destroy, :join, :leave]

  # GET /groups
  # GET /groups.xml
  def index
    if params[:group_type] == "Show" then
      @groups = Show.all
    elsif params[:group_type] == "Board" then
      @groups = Board.all
    elsif params[:group_type] == "Group" then
      @groups = Group.where(:type => nil).all
    elsif params[:group_type] == "all" then
      @groups = Group.all
    else
      @groups = Group.active
    end

    # FIXME This is a bad idea from a performance perspective, but until I have
    # figured out how do to group sorting in the DB, it will have to stay
    @groups = @groups.sort.paginate(:per_page => 20, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
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
    respond_to do |format|
      if @group.update_attributes(params[params[:group_type].downcase])
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
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end

  # POST /groups/1/join
  def join
    unless @group.users.include? current_user then
      role = Role.find_by_name("Member")
      @group.positions.create(:user_id => current_user.id, 
                              :role_id => role.id, 
                              :display_name => "Member")
    else
      flash[:notice] = "You are already a member of this group!"
    end

    redirect_to group_path(@group)
  end
  
  # POST /groups/1/leave
  def leave
    if @group.users.include? current_user then
      @group.positions.where(:user_id => current_user.id).each do |p|
        p.destroy
      end
    else
      flash[:notice] = "You aren't a member of this group!"
    end

    redirect_to group_path(@group)
  end

  protected

  def locate_our_group
    @group = Group.find(params[:id]) if params[:id]
  end

end
