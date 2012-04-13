class Race < ActiveRecord::Base
  belongs_to :voting
  has_many :nominations, :dependent => :destroy
  
  validates_presence_of :name, :grouping
  validates_numericality_of :grouping, :minimum => 1
  
  accepts_nested_attributes_for :nominations, :allow_destroy => true
end
