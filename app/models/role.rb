class Role < ActiveRecord::Base
  has_many :role_permissions
  has_many :permissions, :through => :role_permissions

  validates_inclusion_of :group_type, :in => ["Group", "Show", "Board"]

  # Sort based on the number of permissions
  def <=>(other)
    permissions.count <=> other.permissions.count
  end

  def to_s
    name
  end
end
