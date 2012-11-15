class AddDefaultsToReportFields < ActiveRecord::Migration
  def change
    add_column :report_fields, :default_value, :string
  end
end
