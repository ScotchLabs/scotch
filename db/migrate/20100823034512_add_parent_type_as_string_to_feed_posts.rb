class AddParentTypeAsStringToFeedPosts < ActiveRecord::Migration
  def self.up
    add_column :feed_posts, :parent_type, :string
  end

  def self.down
    remove_column :feed_posts, :parent_type
  end
end
