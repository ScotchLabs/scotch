class Permission < ActiveRecord::Base
  def self.fetch(permName)
    self.find_by_name!(permName)
  end

  def to_s
    name
  end
end
