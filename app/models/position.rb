class Position < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  belongs_to :group

  validates_presence_of :user, :role, :group

  attr_protected :group_id

  def to_s
    display_name
  end

end
