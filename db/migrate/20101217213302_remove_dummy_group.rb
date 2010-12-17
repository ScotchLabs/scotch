class RemoveDummyGroup < ActiveRecord::Migration
  def self.up
    g = Group.find_by_name("Dummy Group")
    g.destroy unless g.nil?
  end

  def self.down
  end
end
