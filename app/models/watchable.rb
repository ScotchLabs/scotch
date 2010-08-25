class Watchable < ActiveRecord::Base
  has_many :watchers, :as => :item, :dependent => :destroy
  has_many :feedposts, :as => :parent, :dependent => :destroy
  
  self.abstract_class = true 
end
