class Folder < ActiveRecord::Base
  belongs_to :group
  belongs_to :folder
  has_many :documents, dependent: :destroy
  has_many :folders, dependent: :destroy
  
  def contents
    self.folders + self.documents
  end
end
