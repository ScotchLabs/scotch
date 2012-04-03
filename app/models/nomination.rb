class Nomination < ActiveRecord::Base
  belongs_to :race
  has_many :nominees, :dependent => :destroy
  has_many :users, :through => :nominees
  
  validates_presence_of :race
  
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
end
