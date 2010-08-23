class Watcher < ActiveRecord::Base
  belongs_to :user
  belongs_to :item, :polymorphic => true
  
  validates_presence_of :user, :item
end
