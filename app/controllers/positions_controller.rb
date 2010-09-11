class PositionsController < ApplicationController
  # populate @position
  prepend_before_filter :locate_position, :only => [:edit, :update, :show, :destroy, :create]

  # Make sure that you can't edit positions for show users, they should only
  # be created or deleted since that's all the UI really supports
  append_before_filter :prevent_show_editing, :only => [:edit, :update]

  before_filter :only => [:edit, :new, :update, :create] do
    require_permission "adminCrew"
  end

  before_filter :only => [:destroy] do
    if @position.role.crew? then
      require_permission "adminCrew"
    else
      require_permission "adminPositions"
    end
  end

  # Users with adminCrew can only create crew members through the bulk_create
  # action.  Yes, this isn't really ideal, but it's a simple way of doing it.
  before_filter :only => [:bulk_create] do
    role = Role.find(params[:role_id])
    if role.crew? then
      require_permission "adminCrew"
    else
      require_permisison "adminPositions"
    end
  end

  # GET /groups/1/positions
  # GET /groups/1/positions.xml
  def index
    @positions = Position.where(:group_id => @group.id).joins(:user).order("users.last_name, users.first_name ASC")
    @positions = @positions.paginate(:per_page => 30, :page => params[:page]) unless @group.type == "Show"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @positions }
    end
  end

  # GET /positions/1
  # GET /positions/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @position }
    end
  end

  # GET /groups/1/positions/new
  # GET /groups/1/positions/new.xml
  def new
    @position = Position.new
    @position.group = @group
    @position.role = Role.find(params[:role_id].to_i) unless params[:role_id].nil?
    @position.display_name = params[:display_name] unless params[:display_name].nil?

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @position }
    end
  end

  # GET /positions/1/edit
  def edit
    @group = @position.group
  end

  # POST /positions
  # POST /positions.xml
  def create
    @position = Position.new(params[:position])
    
    # FIXME this is redundent
    @group = Group.find(params[:position][:group_id])

    @position.user = User.autocomplete_retreive_user(params[:user_identifier]) unless @position.user
    @position.group = @group

    respond_to do |format|
      if @position.save
        format.html { 
          if @group.type == "Show" then
            redirect_to(@group, :notice => 'Position was successfully created.') 
          else
            redirect_to(@position, :notice => 'Position was successfully created.') 
          end
        }
        format.xml  { render :xml => @position, :status => :created, :location => @position }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /positions/bulk_create
  # POST /positions/bulk_create.xml
  # FIXME: validate privilages
  def bulk_create
    role = Role.find(params[:role_id])
    
    users = []

    # FIXME this whole thing is ugly, too many nil? or empty?
    Position.transaction do
      params[:users].each do |user_id_s|
        users << User.find(user_id_s.to_i) unless user_id_s.nil? or user_id_s.empty?
      end if params.has_key?(:users)

      params[:user_identifiers].each do |user_identifier|
        users << User.autocomplete_retreive_user(user_identifier) unless user_identifier.nil? or user_identifier.empty?
      end if params.has_key?(:user_identifiers)

      users.each do |user|
        unless @group.positions.where(:user_id => user.id).where(:display_name => params[:position_name]).count > 0 then
          p = Position.new(:user => user, :role => role, :display_name => params[:position_name])
          p.group = @group
          p.save!
        end
      end
    end

    respond_to do |format|
        format.html { redirect_to(group_positions_path(@group), :notice => 'Position was successfully created.') }
        format.xml  { render :xml => @position, :status => :created, :location => @position } # FIXME broken
    end
  end

  # PUT /positions/1
  # PUT /positions/1.xml
  def update
    respond_to do |format|
      if @position.update_attributes(params[:position])
        format.html { redirect_to(group_positions_url(@position.group), :notice => 'Position was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /positions/1
  # DELETE /positions/1.xml
  def destroy
    @group = @position.group
    @position.destroy

    respond_to do |format|
      format.html { redirect_to(group_positions_url(@group)) }
      format.xml  { head :ok }
    end
  end

  protected

  def locate_position
    @position = Position.find(params[:id]) if params[:id]
    @group = @position.group if @position and @group.nil?

    # FIXME this is ugly Perhaps this and the simmilar line for documents and
    # events can be put in the application controller? or, perhaps those
    # routes should just be scoped to the group
    if @group.nil? and params.has_key? :position and params[:position].has_key? :group_id then
      @group = Group.find(params[:position][:group_id])
    end
  end

  def prevent_show_editing
    redirect_to group_positions_url(@group) if @group.class.name == "Show"
  end
end
