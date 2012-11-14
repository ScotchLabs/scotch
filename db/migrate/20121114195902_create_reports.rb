class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.integer :report_template_id
      t.integer :creator_id
      t.integer :document_id

      t.timestamps
    end
  end
end
