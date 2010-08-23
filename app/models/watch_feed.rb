module WatchFeed
  def watchers
    Watcher.where(:item_type => self.class.to_s, :item_id => self.id)
  end
  
  def feed_posts
    FeedPost.where(:parent_type => self.class.to_s, :parent_id => self.id)
  end
  
  def recent_posts
    FeedPost.where(:parent_type => self.class.to_s, :parent_id => self.id).order("created_at DESC").limit(10)
  end
end
