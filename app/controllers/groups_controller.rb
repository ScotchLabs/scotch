class GroupsController < ApplicationController
  layout 'group', :except => [:index, :new]

  before_filter :only => [:new, :create] do
    if params[:group_type] == "Show" then
      require_global_permission "createShow"
    elsif params[:group_type] == "Board" then
      require_global_permission "createBoard"
    else
      require_global_permission "createGroup"
    end
  end

  before_filter :only => [:edit, :update] do
    require_permission "adminGroup"
  end

  append_before_filter :only => [:signup, :leave] do
    if @group.class.name != "Group" then
      flash[:notice] = "You can not signup or leave a non-group"
      redirect_to (@group or groups_url)
    end
  end

  prepend_before_filter :locate_our_group, :only => [:show, :edit, :update, :destroy, :join, :leave, :archive]

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
    # FIXME we can't paginate until we do sorting in the db
    @groups = @groups.sort

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
    elsif params[:group_type] == "Board" then
      @group = Board.new
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
      @group = Show.new(params[:group])
    elsif params[:group_type] == "Board" then
      @group = Board.new(params[:group])
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
    # I'm not sure when it actually uses the type in the name, but it seems
    # inconsistent, so we'll try both for now
    if params.has_key? params[:group_type].downcase then
      data = params[params[:group_type].downcase]
    else
      data = params[:group]
    end

    respond_to do |format|
      if @group.update_attributes(data)
        format.html { redirect_to(@group, :notice => 'Group was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
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

  def archive
    if @group.archived? then
      flash[:notice] = "This group is already archived."
      redirect_to group_path(@group)
      return
    end


    if @group.class.name != "Board"
      @group.archive_date = 1.day.ago
      @group.save!
      redirect_to group_path(@group)
      return
    end

    Board.transaction do
      new_group = @group.clone
      new_group.name = new_group.name + " (#{params[:title]})"
      new_group.short_name = new_group.short_name + "_#{params[:title].gsub(/[^-_0-9a-zA-Z]/,'')}"
      new_group.archive_date = 1.day.ago
      new_group.save!

      @group.positions.each do |p|
        p.group_id = new_group.id
        p.save!
      end

      @group = new_group
    end

    redirect_to group_path(@group)
  end

  protected

  def locate_our_group
    @group = Group.find(params[:id]) if params[:id]
  end

end
