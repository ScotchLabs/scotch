class DocumentTagsController < ApplicationController
  # GET /document_tags
  # GET /document_tags.xml
  def index
    @document_tags = DocumentTag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @document_tags }
    end
  end

  # GET /document_tags/1
  # GET /document_tags/1.xml
  def show
    @document_tag = DocumentTag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document_tag }
    end
  end

  # GET /document_tags/new
  # GET /document_tags/new.xml
  def new
    @document_tag = DocumentTag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @document_tag }
    end
  end

  # GET /document_tags/1/edit
  def edit
    @document_tag = DocumentTag.find(params[:id])
  end

  # POST /document_tags
  # POST /document_tags.xml
  def create
    @document_tag = DocumentTag.new(params[:document_tag])

    respond_to do |format|
      if @document_tag.save
        format.html { redirect_to(@document_tag, :notice => 'Document tag was successfully created.') }
        format.xml  { render :xml => @document_tag, :status => :created, :location => @document_tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @document_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /document_tags/1
  # PUT /document_tags/1.xml
  def update
    @document_tag = DocumentTag.find(params[:id])

    respond_to do |format|
      if @document_tag.update_attributes(params[:document_tag])
        format.html { redirect_to(@document_tag, :notice => 'Document tag was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @document_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /document_tags/1
  # DELETE /document_tags/1.xml
  def destroy
    @document_tag = DocumentTag.find(params[:id])
    @document_tag.destroy

    respond_to do |format|
      format.html { redirect_to(document_tags_url) }
      format.xml  { head :ok }
    end
  end
end
