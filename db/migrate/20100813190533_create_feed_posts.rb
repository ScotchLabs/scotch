class CreateFeedPosts < ActiveRecord::Migration
  def self.up
    create_table :feed_posts do |t|
      t.integer :parent_id
      t.integer :user_id
      t.string :post_type
      t.string :headline
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :feed_posts
  end
end
