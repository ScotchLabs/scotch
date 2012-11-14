class CreateReportValues < ActiveRecord::Migration
  def change
    create_table :report_values do |t|
      t.integer :report_id
      t.integer :report_field_id
      t.string :value

      t.timestamps
    end
  end
end
