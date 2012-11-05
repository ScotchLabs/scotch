class CreateReportFields < ActiveRecord::Migration
  def change
    create_table :report_fields do |t|
      t.integer :report_template_id
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
