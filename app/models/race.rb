class Race < ActiveRecord::Base
  belongs_to :voting, :inverse_of => :races
  has_many :nominations, :dependent => :destroy, :inverse_of => :race
  has_many :votes, :through => :nominations, :inverse_of => :race
  
  validates_presence_of :name, :grouping
  validates_numericality_of :grouping, :minimum => 1

  attr_accessible :nominations_attributes, :name, :grouping, :voting_id, :write_in_available
  
  accepts_nested_attributes_for :nominations, :allow_destroy => true

  def to_s
    name
  end
end
