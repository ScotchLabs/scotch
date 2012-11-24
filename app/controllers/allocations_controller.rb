class AllocationsController < ApplicationController
  # GET /allocations
  # GET /allocations.json
  def index
    @allocations = Allocation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @allocations }
    end
  end

  # GET /allocations/1
  # GET /allocations/1.json
  def show
    @allocation = Allocation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @allocation }
    end
  end

  # GET /allocations/new
  # GET /allocations/new.json
  def new
    @allocation = Allocation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @allocation }
    end
  end

  # GET /allocations/1/edit
  def edit
    @allocation = Allocation.find(params[:id])
  end

  # POST /allocations
  # POST /allocations.json
  def create
    @allocation = Allocation.new(params[:allocation])

    respond_to do |format|
      if @allocation.save
        format.html { redirect_to @allocation, notice: 'Allocation was successfully created.' }
        format.json { render json: @allocation, status: :created, location: @allocation }
      else
        format.html { render action: "new" }
        format.json { render json: @allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /allocations/1
  # PUT /allocations/1.json
  def update
    @allocation = Allocation.find(params[:id])

    respond_to do |format|
      if @allocation.update_attributes(params[:allocation])
        format.html { redirect_to @allocation, notice: 'Allocation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @allocation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allocations/1
  # DELETE /allocations/1.json
  def destroy
    @allocation = Allocation.find(params[:id])
    @allocation.destroy

    respond_to do |format|
      format.html { redirect_to allocations_url }
      format.json { head :no_content }
    end
  end
end
