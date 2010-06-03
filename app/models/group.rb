class Group < ActiveRecord::Base

  has_many :checkouts
  has_many :documents
  has_many :events

end
