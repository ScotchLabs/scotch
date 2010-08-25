class Watchable < ActiveRecord::Base
  has_many :watchers, :as => :parent
  has_many :feedposts, :as => :parent
  
  self.abstract_class = true 
end
