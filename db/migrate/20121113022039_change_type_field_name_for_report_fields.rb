class ChangeTypeFieldNameForReportFields < ActiveRecord::Migration
  def change
    add_column :report_fields, :field_type, :string
    remove_column :report_fields, :type
  end
end
