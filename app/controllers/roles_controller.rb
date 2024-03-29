class RolesController < ApplicationController

  before_filter :only => [:new, :create, :update, :destroy, :edit] do
    require_global_permission "adminRoles"
  end

  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    Role.transaction do
      @role = Role.new(params[:role])
      @role.permissions = params_permissions

      respond_to do |format|
        if @role.save
          format.html { redirect_to(@role, :notice => 'Role was successfully created.') }
          format.xml  { render :xml => @role, :status => :created, :location => @role }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
        end
      end
    end # end transaction
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])

    Role.transaction do
      @role.permissions = params_permissions

      respond_to do |format|
        if @role.update_attributes(params[:role])
          format.html { redirect_to(@role, :notice => 'Role was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end

  private

  def params_permissions
    return [] unless params.has_key? "permission"

    perms = []
    params["permission"].each do |k,v|
      if v.to_i == 1 then
        perms << Permission.find(k.to_i)
      end
    end

    return perms
  end
end
