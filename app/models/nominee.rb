class Nominee < ActiveRecord::Base
  belongs_to :user
  belongs_to :nomination
  has_one :race, :through => :nomination
  
  validates_presence_of :nomination, :user
end
