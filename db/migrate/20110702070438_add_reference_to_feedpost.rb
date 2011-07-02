class AddReferenceToFeedpost < ActiveRecord::Migration
  def self.up
    add_column :feedposts, :reference_id, :integer
    add_column :feedposts, :reference_type, :string
  end

  def self.down
    remove_column :feedposts, :reference_id
    remove_column :feedposts, :reference_type
  end
end
