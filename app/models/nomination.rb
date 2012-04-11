class Nomination < ActiveRecord::Base
  include Comparable
  
  belongs_to :race
  has_many :nominees, :dependent => :destroy
  has_many :users, :through => :nominees
  
  before_create :nomination_full?
  
  accepts_nested_attributes_for :nominees, :allow_destroy => true
  
  def <=>(other)
    if self.accepted === other.accepted
      return 0
    elsif self.accepted === true
      return -1
    elsif other.accepted === true
      return 1
    elsif self.accepted === false
      return 1
    else
      return -1
    end
  end
  
  def accepted?
    accepted===true
  end
  def rejected?
    accepted===false
  end
  
  private
  
  def nomination_full?
    self.nominees.count >= self.race.grouping
  end
end
