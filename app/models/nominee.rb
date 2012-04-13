class Nominee < ActiveRecord::Base
  belongs_to :user
  belongs_to :nomination
  has_one :race, :through => :nomination
  
  before_create :is_valid_user?
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
  
  private
  
  def is_valid_user?
    !self.user_id.nil?
  end
  
  def nomination_full?
    self.nomination.nominees.count < self.nomination.race.grouping
  end
end
