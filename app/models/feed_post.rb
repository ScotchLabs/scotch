class FeedPost < ActiveRecord::Base
  include WatchFeed
  
  belongs_to :parent, :polymorphic => true
  belongs_to :user
  
  attr_protected :user_id
  
  #FIXME what other types are there and
  # what differentiates them?
  POST_TYPES = [
    ['wall',"Wallpost"]
  ]
  
  validates_presence_of :parent, :user
  validates_length_of :headline, :maximum => 140, :message => "may not be more than 140 characters."
  validates_inclusion_of :post_type, :in => POST_TYPES.map{|e| e[0]}, :message => "is not included in the list #{POST_TYPES.map{|e| e[0]}.inspect}"
end
