class Folder < ActiveRecord::Base
  belongs_to :group
  belongs_to :folder
  has_many :documents, dependent: :destroy
  has_many :folders, dependent: :destroy
  
  def contents
    self.folders + self.documents
  end
  
  def breadcrumbs
    if self.folder
      self.folder.breadcrumbs + [self]
    else
      [self]
    end
  end
end
