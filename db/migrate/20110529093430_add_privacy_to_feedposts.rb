class AddPrivacyToFeedposts < ActiveRecord::Migration
  def self.up
    add_column :feedposts, :privacy, :string, :default => "All"
  end

  def self.down
    remove_column :feedposts, :privacy
  end
end
