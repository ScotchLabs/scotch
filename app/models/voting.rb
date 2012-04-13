class Voting < ActiveRecord::Base
  has_many :races, :dependent => :destroy
  belongs_to :group
  
  VOTING_TYPES = [
    ['Election','election'],
    ['Award','award']
  ]
  def self.VOTING_TYPES
    VOTING_TYPES
  end
  
  attr_accessible :voting_type, :name, :open_date, :close_date, :vote_date, :press_date, :races_attributes, :group_id
  
  accepts_nested_attributes_for :races, :allow_destroy => true
  
  scope :future, where(["open_date > ?",Date.today])
  scope :open, where(["open_date <= ? and close_date >= ?",Date.today,Date.today()])
  scope :past, where(["close_date < ?",Date.today()])
  
  scope :election, where(:voting_type => 'election')
  scope :award, where(:voting_type => "award")
  
  validates_inclusion_of :voting_type, :in => VOTING_TYPES.map{|f| f[1]}, :message => "must be some value in #{VOTING_TYPES.map{|f| f[1]}}"
  validates_presence_of :name, :open_date, :close_date, :vote_date, :press_date
  validate :dates_are_sane
  
  def future?
    #,4)
    open_date > Date.today
  end
  def open_for_nominations?
    #[4,8)
    open_date <= Date.today and vote_date > Date.today
  end
  def open_for_votes?
    #[8,10)
    vote_date <= Date.today and close_date > Date.today
  end
  def open?
    open_for_nominations? or open_for_votes?
  end
  def closed_for_nominations?
    !open_for_nominations?
  end
  def closed_for_votes?
    #[10,12)
    close_date <= Date.today and press_date > Date.today
  end
  def past?
    #[12,
    press_date <= Date.today
  end
  
  def election?
    voting_type=='election'
  end
  def award?
    voting_type=='award'
  end

  def to_s
    name
  end
  
protected
  def dates_are_sane
    errors[:close_date] << "must be after open date" if close_date <= open_date
    errors[:press_date] << "must be after close date" if press_date < close_date
    if election?
      errors[:vote_date] << "must be the same as the close date" if vote_date != close_date
    elsif award?
      errors[:vote_date] << "must be between open and closed dates" if vote_date < open_date or vote_date >= close_date
    end
  end
end
