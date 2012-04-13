class Nominee < ActiveRecord::Base
  belongs_to :user
  belongs_to :nomination
  has_one :race, :through => :nomination
  
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
