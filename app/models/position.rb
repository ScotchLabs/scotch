class Position < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  belongs_to :group

  validates_presence_of :user_id, :role_id, :group_id

  attr_protected :group_id

  validate :role_matches_group

  def to_s
    display_name
  end

  def <=>(other)
    gsort = group<=>other.group
    if gsort == 0
      role <=> other.role || display_name <=> other.display_name
    else
      return gsort
    end
  end

  protected

  def role_matches_group
    unless role.group_type == group.class.name
      errors[:role] << "isn't aproproate for this group"
    end
  end

end
