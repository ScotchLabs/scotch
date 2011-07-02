# == Schema Information
#
# Table name: feedpost_attachments
#
#  id          :integer(4)      not null, primary key
#  feedpost_id :integer(4)
#  document_id :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class FeedpostAttachment < ActiveRecord::Base
  belongs_to :feedpost
  belongs_to :document

  validates_presence_of :feedpost
  validates_presence_of :document
end
