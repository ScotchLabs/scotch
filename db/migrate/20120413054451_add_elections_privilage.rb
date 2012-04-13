class AddElectionsPrivilage < ActiveRecord::Migration
  def self.up
    p = Permission.create(:name => "adminElection", :description => "User can admin elections.")
  end

  def self.down
  end
end
