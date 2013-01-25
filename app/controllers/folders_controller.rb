class FoldersController < ApplicationController
  layout 'group'
  
  before_filter :get_folder, except: [:new, :create]
  
  # GET /folders
  # GET /folders.json
  def index
    @folders = Folder.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @folders }
    end
  end

  # GET /folders/1
  # GET /folders/1.json
  def show
    @documents = @folder.contents
    
    @breadcrumbs = @folder.breadcrumbs

    respond_to do |format|
      format.html { render 'documents/index' }
      format.json { render json: @folder }
    end
  end

  # GET /folders/new
  # GET /folders/new.json
  def new
    @folder = Folder.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @folder }
    end
  end

  # GET /folders/1/edit
  def edit
    
  end

  # POST /folders
  # POST /folders.json
  def create
    @folder = @group.folders.new(params[:folder])

    respond_to do |format|
      if @folder.save
        format.html { redirect_to @folder, notice: 'Folder was successfully created.' }
        format.json { render json: @folder, status: :created, location: @folder }
      else
        format.html { render action: "new" }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /folders/1
  # PUT /folders/1.json
  def update

    respond_to do |format|
      if @folder.update_attributes(params[:folder])
        format.html { redirect_to @folder, notice: 'Folder was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folders/1
  # DELETE /folders/1.json
  def destroy
    @group = @folder.group
    @folder.destroy

    respond_to do |format|
      format.html { redirect_to group_documents_url(@group) }
      format.json { head :no_content }
    end
  end
  
  protected
  
  def get_folder
    @folder = Folder.find(params[:id])
    @group = @folder.group if @folder and @group.nil?
  end
end
