class Nominee < ActiveRecord::Base
  belongs_to :user
  belongs_to :nomination
  has_one :race, :through => :nomination
  
  validates_presence_of :nomination, :user
  
  def to_s
    return write_in if write_in
    user.name
  end
end
