class RemoveParentTypeFromFeedPosts < ActiveRecord::Migration
  def self.up
    remove_column :feed_posts, :parent_type
  end

  def self.down
    add_column :feed_posts, :parent_type, :integer
  end
end
