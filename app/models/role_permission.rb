# == Schema Information
#
# Table name: role_permissions
#
#  id            :integer(4)      not null, primary key
#  role_id       :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  permission_id :integer(4)
#

class RolePermission < ActiveRecord::Base
  belongs_to :role
  belongs_to :permission

  validates_presence_of :role_id, :permission_id
end
