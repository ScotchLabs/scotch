class Position < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  belongs_to :group

  validates_presence_of :user_id, :role_id, :group_id

  attr_protected :group_id

  def to_s
    display_name
  end

  def <=>(other)
    role <=> other.role || display_name <=> other.display_name
  end

end
