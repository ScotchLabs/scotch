class DocumentsController < ApplicationController
  layout 'group'
  
  prepend_before_filter :locate_document, :only => [:edit, :update, :show, :destroy, :signup, :create]

  append_before_filter :get_popular_tags, :only => [:edit, :new, :create]

  append_after_filter :create_feedpost, :only => [:create]

  before_filter :only => [:new, :edit, :create, :update, :destroy] do 
    require_permission "uploadDocument"
  end

  before_filter :only => [:new, :edit, :create, :update, :destroy] do 
    require_permission "adminDocuments"
  end

  # GET /groups/1/documents
  # GET /groups/1/documents.xml
  def index
    @documents = @group.main_folder
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
    end
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /groups/1/documents/new
  # GET /groups/1/documents/new.xml
  def new
    @document = Document.new
    @document.group = @group

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document }
    end
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.xml
  def create
    @document = @group.documents.new(params[:document])

    respond_to do |format|
      if @document.save
        format.html { redirect_to(@document, :notice => 'Document was successfully created.') }
        format.xml  { render :xml => @document, :status => :created, :location => @document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.xml
  def update
    respond_to do |format|
      if @document.update_attributes(params[:document])
        format.html { redirect_to(@document, :notice => 'Document was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.xml
  def destroy
    @document.destroy

    respond_to do |format|
      format.html { redirect_to(documents_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def locate_document
    @document = Document.find(params[:id]) if params[:id]
    @group = @document.group if @document and @group.nil?

    # FIXME this is ugly
    if @group.nil? and params.has_key? :document and params[:document].has_key? :group_id then
      @group = Group.find(params[:document][:group_id])
    end
  end

  def get_popular_tags
    @popular_tags = Document.tag_counts_on(:tags).limit(10)
  end

  def create_feedpost
    return if @document.new_record?
    f = Feedpost.new
    f.post_type = "create"
    f.user = current_user
    f.reference = @document
    f.parent = @document.group
    f.headline = "uploaded a document"
    f.body = @document.description
    f.save
  end
end
