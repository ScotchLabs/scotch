class RemoveDocumentTag < ActiveRecord::Migration
  def self.up
    drop_table :document_tags
  end

  def self.down
  end
end
