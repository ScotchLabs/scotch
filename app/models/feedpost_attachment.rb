class FeedpostAttachment < ActiveRecord::Base
  belongs_to :feedpost
  belongs_to :document

  validates_presence_of :feedpost
  validates_presence_of :document
end
