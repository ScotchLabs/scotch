class AddSubHeadingsToReportTemplate < ActiveRecord::Migration
  def change
    add_column :report_templates, :sub_heading, :string
    add_column :report_templates, :sub_heading_default, :string
    add_column :report_templates, :sub_heading2, :string
    add_column :report_templates, :sub_heading2_default, :string
  end
end
