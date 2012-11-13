class AddFieldOrderToReportFields < ActiveRecord::Migration
  def change
    add_column :report_fields, :field_order, :integer

  end
end
