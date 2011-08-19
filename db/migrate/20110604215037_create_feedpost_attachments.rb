class CreateFeedpostAttachments < ActiveRecord::Migration
  def self.up
    create_table :feedpost_attachments do |t|
      t.integer :feedpost_id
      t.integer :document_id

      t.timestamps
    end
  end

  def self.down
    drop_table :feedpost_attachments
  end
end
