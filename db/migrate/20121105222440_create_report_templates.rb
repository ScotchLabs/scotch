class CreateReportTemplates < ActiveRecord::Migration
  def change
    create_table :report_templates do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
