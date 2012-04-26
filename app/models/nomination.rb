class Nomination < ActiveRecord::Base
  include Comparable
  
  belongs_to :race, :inverse_of => :nominations
  validates_presence_of :race
  has_one :voting, :through => :race

  has_many :nominees, :dependent => :destroy, :inverse_of => :nomination
  has_many :users, :through => :nominees
  has_many :votes, :dependent => :destroy, :inverse_of => :nomination

  has_many :feedposts, :as => :parent, :dependent => :destroy, :include => :user

  # FIXME: This is vulnerable to mass-assignment on winner and accepted
  attr_accessible :race_id, :platform, :tagline, :nominees_attributes, :winner, :accepted
  
  accepts_nested_attributes_for :nominees, :allow_destroy => true

  validates_length_of :tagline, :maximum => 90
  
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

  def names
    nominees.to_sentence
  end

  def to_s
    return "#{names} for #{race}"
  end
end
