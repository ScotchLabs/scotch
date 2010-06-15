class Permission < ActiveRecord::Base
  def self.get(permName)
    self.where(:name => permName).first
  end

  def to_s
    name
  end
end
