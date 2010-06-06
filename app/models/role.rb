class Role < ActiveRecord::Base
  has_many :role_permissions
  has_many :permissions, :through => :role_permissions

  # Sort based on the number of permissions
  def <=>(other)
    permissions <=> other.permissions
  end

  def to_s
    name
  end
end
