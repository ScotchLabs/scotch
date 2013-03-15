class CreatePageSections < ActiveRecord::Migration
  def change
    create_table :page_sections do |t|
      t.integer :page_id
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
