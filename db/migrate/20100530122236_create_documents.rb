class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :name
      t.integer :group_id
      t.string :filename
      t.string :mime_type

      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
