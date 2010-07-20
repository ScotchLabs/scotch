class AddBirthyearToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birthyear, :integer
  end

  def self.down
    remove_column :users, :birthyear
  end
end
