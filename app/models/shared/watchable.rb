module Shared
  class Watchable < ActiveRecord::Base
    has_many :watchers, :as => :item, :dependent => :destroy, :include => :user
    has_many :feedposts, :as => :parent, :dependent => :destroy, :include => :user
    
    self.abstract_class = true 
  end
end
