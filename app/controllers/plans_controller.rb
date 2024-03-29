class PlansController < ApplicationController
  layout 'group'
  before_filter :get_plan, except: [:index, :new, :create]
  before_filter :get_group, except: [:index, :new, :create]

  before_filter :only => [:new, :edit, :update, :create, :destroy, :complete] do
    require_permission 'adminCrew'
  end

  # GET /plans
  # GET /plans.json
  def index
    @plans = @group.plans

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @plans }
    end
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    @tasks = @plan.tasks.order('start_time ASC')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @plan }
    end
  end

  def gantt

    respond_to do |format|
      format.json {render json: @plan}
    end
  end

  # GET /plans/new
  # GET /plans/new.json
  def new
    @plan = Plan.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @plan }
    end
  end

  # GET /plans/1/edit
  def edit
  end

  # POST /plans
  # POST /plans.json
  def create
    @plan = @group.plans.new(params[:plan])

    respond_to do |format|
      if @plan.save
        format.html { redirect_to @plan, notice: 'Plan was successfully created.' }
        format.json { render json: @plan, status: :created, location: @plan }
      else
        format.html { render action: "new" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /plans/1
  # PUT /plans/1.json
  def update

    respond_to do |format|
      if @plan.update_attributes(params[:plan])
        format.html { redirect_to @plan, notice: 'Plan was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    @plan.destroy

    respond_to do |format|
      format.html { redirect_to plans_url }
      format.json { head :no_content }
    end
  end

  protected

  def get_plan
    @plan = Plan.find(params[:id])
  end

  def get_group
    @group = @plan.group
  end
end
