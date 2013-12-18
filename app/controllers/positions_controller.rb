class PositionsController < ApplicationController
  layout 'group'
  # populate @position
  prepend_before_filter :locate_position, :only => [:destroy, :create]

  before_filter :only => [:new] do
    require_permission "adminCrew"
  end

  before_filter :only => [:destroy] do
    if @position.role.crew? then
      require_permission "adminCrew"
    else
      require_permission "adminPositions"
    end
  end

  before_filter :only => [:create] do
    require_permission "adminPositions"
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

    @roster = {}

    @positions.each do |p|
      @roster[p.user.name.capitalize[0]] = [] if !@roster[p.user.name.capitalize[0]]
      @roster[p.user.name.capitalize[0]] << p
    end

    respond_to do |format|
      format.html # index.html.erb
      format.pdf
      format.xml  { render :xml => @positions }
      format.json {
        p = {}
        @positions.each do |position|
          unless p.has_key? position.display_name
            p[position.display_name] = []
          end
          pos = {}
          pos["name"] = position.user.name
          pos["andrewid"] = position.user.andrewid
          p[position.display_name].push pos
        end
        p=p.map{|k, v| {"display_name" => k, "users" => v}}
        render :json => p
      }
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

  # POST /positions
  # POST /positions.xml
  def create
    @position = @group.positions.new(params[:position])
    
    @position.user = User.find_by_andrewid(params[:position][:andrewid]) unless @position.user

    respond_to do |format|
      if @position.save
        format.html { redirect_to(group_positions_url(@group)) }
        format.xml  { render :xml => @position, :status => :created, :location => @position }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /positions/bulk_create
  # POST /positions/bulk_create.xml
  # FIXME: validate privileges
  def bulk_create
    role = Role.find(params[:role_id])
    
    users = []
    
    ok = true

    # FIXME this whole thing is ugly, too many nil? or empty?
    Position.transaction do
      params[:users].each do |user_id_s|
        users << User.find(user_id_s.to_i) unless user_id_s.nil? or user_id_s.empty?
      end if params.has_key?(:users)

      params[:user_identifiers].each do |user_identifier|
        users << User.autocomplete_retreive_user(user_identifier) unless user_identifier.nil? or user_identifier.empty?
      end if params.has_key?(:user_identifiers)

      users.compact! #remove any nils
      
      users.each do |user|
        unless @group.positions.where(:user_id => user.id).where(:display_name => params[:position_name]).count > 0 then
          p = Position.new(:user => user, :role => role, :display_name => params[:position_name])
          p.group = @group
          ok = false unless p.save
        end
      end
    end

    if ok
      respond_to do |format|
          format.html { redirect_to(group_positions_path(@group), :notice => 'Position was successfully created.') }
          format.xml  { render :xml => @position, :status => :created, :location => @position } # FIXME broken
      end
    else
      redirect_to(group_positions_path(@group), :alert => "There was an error creating the positions")
      return nil
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

end
