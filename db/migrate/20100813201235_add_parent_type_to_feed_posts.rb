class AddParentTypeToFeedPosts < ActiveRecord::Migration
  def self.up
    add_column :feed_posts, :parent_type, :integer
  end

  def self.down
    remove_column :feed_posts, :parent_type
  end
end
