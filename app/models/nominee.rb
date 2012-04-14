class Nominee < ActiveRecord::Base
  belongs_to :nomination, :inverse_of => :nominees
  validates_presence_of :nomination

  has_one :race, :through => :nomination
  
  belongs_to :user
  validates_presence_of :user, :if => Proc.new {|n| n.write_in.nil? || n.write_in.empty?}

  validates_length_of :write_in, :minimum => 3, :if => Proc.new {|n| n.user.nil?}

  before_create :nomination_full?
  
  def to_s
    return write_in if write_in
    user.name
  end
  
  def andrew_id
    self.user.andrewid if self.user
  end
  
  def andrew_id=(andrew)
    self.user_id = User.find_by_andrewid(andrew).try(:id)
  end
  
  def is_valid_user?
    not self.user_id.nil?
  end

  private
  
  def nomination_full?
    self.nomination.nominees.count < self.nomination.race.grouping
  end
end
