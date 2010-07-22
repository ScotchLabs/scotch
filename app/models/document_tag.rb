class DocumentTag < ActiveRecord::Base
  belongs_to :document

  validates_presence_of :document_id, :name
end
