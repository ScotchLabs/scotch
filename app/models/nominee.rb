class Nominee < ActiveRecord::Base
  belongs_to :user
  belongs_to :nomination
  has_one :race, :through => :nomination
  
  before_create :is_valid_user?
  
  def to_s
    return write_in if write_in
    user.name
  end
  
  def andrew_id
    self.user.andrewid if self.user
  end
  
  def andrew_id=(andrew)
    self.user = User.find_by_andrewid(andrew)
  end
  
  private
  
  def is_valid_user?
    !self.user.nil?
  end
end
