class TasksController < ApplicationController
  before_filter :get_plan, only: [:index, :new, :create]
  before_filter :get_task, except: [:index, :new, :create]
  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = @plan.tasks

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
  end

  def complete
    @task.completed_time = DateTime.now

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task.plan, notice: 'Task was successfully completed.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = @plan.tasks.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to @plan, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end

  protected

  def get_plan
    @plan = Plan.find(params[:plan_id])
  end

  def get_task
    @task = Task.find(params[:id])
  end
end
