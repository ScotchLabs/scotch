class Nomination < ActiveRecord::Base
  include Comparable
  
  belongs_to :race, :inverse_of => :nominations
  validates_presence_of :race

  has_many :nominees, :dependent => :destroy, :inverse_of => :nomination
  has_many :users, :through => :nominees
  has_many :votes, :dependent => :destroy, :inverse_of => :nomination

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
    race.voting.award? or (accepted == true)
  end
  def rejected?
    race.voting.election? and (accepted == false)
  end

  def seconded?
    race.voting.election? and (votes.count > 1)
  end

  def needs_second?
    race.voting.election? and (votes.count <= 1)
  end

  def to_s
    nominees.to_sentence
  end
end
