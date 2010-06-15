class Document < ActiveRecord::Base
  belongs_to :group
  has_many :document_tags

  attr_protected :group_id

  validates_presence_of :group_id
end
