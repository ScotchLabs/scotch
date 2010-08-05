class AddUserPrivacy < ActiveRecord::Migration
  def self.up
    add_column :users, :public_profile, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :public_profile
  end
end
