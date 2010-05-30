class CreateDocumentTags < ActiveRecord::Migration
  def self.up
    create_table :document_tags do |t|
      t.string :name
      t.integer :document_id

      t.timestamps
    end
  end

  def self.down
    drop_table :document_tags
  end
end
