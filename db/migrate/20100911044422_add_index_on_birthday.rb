class AddIndexOnBirthday < ActiveRecord::Migration
  def self.up
    add_index :users, :birthday
  end

  def self.down
  end
end
