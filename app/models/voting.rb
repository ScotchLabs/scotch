class Voting < ActiveRecord::Base
  has_many :races, :dependent => :destroy
  
  VOTING_TYPES = [
    ['Election','election'],
    ['Award','award']
  ]
  def self.VOTING_TYPES
    VOTING_TYPES
  end
  
  attr_accessible :voting_type, :name, :open_date, :close_date, :vote_date
  
  validates_inclusion_of :voting_type, :in => VOTING_TYPES.map{|f| f[1]}, :message => "must be some value in #{VOTING_TYPES.map{|f| f[1]}}"
  validates_presence_of :name, :open_date, :close_date, :vote_date
  validate :dates_are_sane
  
protected
  def dates_are_sane
    puts self.inspect
    errors[:open_date] << "must be in the future" unless open_date >= Date.today
    errors[:close_date] << "must be in the future" unless close_date > Date.today
    errors[:vote_date] << "must be in the future" unless vote_date > Date.today
    errors[:close_date] << "must be after open date" if close_date < open_date
    errors[:vote_date] << "must be between open and closed dates" if vote_date < open_date or vote_date > close_date
  end
end
