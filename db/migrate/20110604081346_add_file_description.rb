class AddFileDescription < ActiveRecord::Migration
  def self.up
    add_column :documents, :description, :text
  end

  def self.down
    remove_column :documents, :description
  end
end
