class RenameFeedPosts < ActiveRecord::Migration
  def self.up
    rename_table :feed_posts, :feedposts
  end

  def self.down
    rename_table :feedposts, :feed_posts
  end
end
