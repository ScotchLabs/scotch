class ReportsController < ApplicationController
  layout 'group'

  before_filter :get_report, except: [:index, :new, :create]
  before_filter :get_group, except:[:index, :new, :create]
  
  before_filter do
    has_permission?('adminDocuments')
  end

  # GET /reports
  # GET /reports.json
  def index
    @reports = @group.reports

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reports }
    end
  end

  # GET /reports/1
  # GET /reports/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @report }
      format.pdf
    end
  end

  # GET /reports/new
  # GET /reports/new.json
  def new
    if params[:template]
      @report_template = ReportTemplate.find(params[:template])
      @report = Report.new

      @report_template.report_fields.editable.each do |r|
        @report.report_values.build({report_field_id: r.id})
      end
    else
      @report_templates = ReportTemplate.all
    end

    respond_to do |format|
      if @report
        format.html # new.html.erb
      else
        format.html { render 'select_template' }
      end
    end
  end

  # GET /reports/1/edit
  def edit
    @report_template = @report.report_template
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = @group.reports.new(params[:report])
    @report.creator = current_user

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render json: @report, status: :created, location: @report }
      else
        format.html { render action: "new" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reports/1
  # PUT /reports/1.json
  def update

    respond_to do |format|
      if @report.update_attributes(params[:report])
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end

  protected

  def get_report
    @report = Report.find(params[:id])
  end

  def get_group
    @group = @report.group
  end
end
