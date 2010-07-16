class PositionsController < ApplicationController
  # populate @position
  prepend_before_filter :locate_position, :only => [:edit, :update, :show, :destroy]

  # Make sure that you can't edit positions for show users, they should only
  # be created or deleted since that's all the UI really supports
  append_before_filter :prevent_show_editing, :only => [:edit, :update]

  # GET /groups/1/positions
  # GET /groups/1/positions.xml
  def index
    @positions = Position.where(:group_id => @group.id).all

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
    @group = Group.find(params[:position][:group_id])

    @position.group = @group

    respond_to do |format|
      if @position.save
        format.html { redirect_to(@position, :notice => 'Position was successfully created.') }
        format.xml  { render :xml => @position, :status => :created, :location => @position }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @position.errors, :status => :unprocessable_entity }
      end
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
    @group = @position.group if @group.nil?
  end

  def prevent_show_editing
    logger.debug("group (#{@group}) type is #{@group.class.name}")
    redirect_to group_positions_url(@group) if @group.class.name == "Show"
  end
end
