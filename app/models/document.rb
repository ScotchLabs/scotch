class Document < ActiveRecord::Base
  belongs_to :group
  has_many :document_tags
end
