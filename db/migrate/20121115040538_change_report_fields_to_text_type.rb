class ChangeReportFieldsToTextType < ActiveRecord::Migration
  def change
    remove_column :report_fields, :default_value
    remove_column :report_values, :value

    add_column :report_fields, :default_value, :text
    add_column :report_values, :value, :text
  end
end
