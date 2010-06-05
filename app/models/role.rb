class Role < ActiveRecord::Base
  has_many :role_permissions
  has_many :permissions, :through => :role_permissions
end
