class Voter < ActiveRecord::Base
  belongs_to :user
  belongs_to :voting
  
  has_many :votes
end
