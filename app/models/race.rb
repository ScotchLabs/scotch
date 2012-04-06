class Race < ActiveRecord::Base
  belongs_to :voting
  has_many :nominations, :dependent => :destroy
  
  validates_presence_of :voting, :name, :grouping
  validates_numericality_of :grouping, :minimum => 1
end
