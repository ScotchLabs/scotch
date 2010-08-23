class Document < ActiveRecord::Base
  include WatchFeed
  
  has_many :document_tags
  
  belongs_to :group

  attr_protected :group_id

  validates_presence_of :group_id
end
