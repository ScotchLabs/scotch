# == Schema Information
#
# Table name: permissions
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Permission < ActiveRecord::Base
  def self.fetch(permName)
    self.find_by_name!(permName)
  end

  def to_s
    name
  end
end
