class Watchable < ActiveRecord::Base
  has_many :watchers, :as => :parent
  has_many :feed_posts, :as => :parent
  
  self.abstract_class = true 
end
