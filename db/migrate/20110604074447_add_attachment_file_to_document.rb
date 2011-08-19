class AddAttachmentFileToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :file_file_name, :string
    add_column :documents, :file_content_type, :string
    add_column :documents, :file_file_size, :integer
    add_column :documents, :file_updated_at, :datetime
    remove_column :documents, :filename
    remove_column :documents, :mime_type
  end

  def self.down
    remove_column :documents, :file_file_name
    remove_column :documents, :file_content_type
    remove_column :documents, :file_file_size
    remove_column :documents, :file_updated_at
    add_column :documents, :filename, :string
    add_column :documents, :mime_type, :string
  end
end
