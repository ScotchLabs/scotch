class ChangeBirthdayInUsersToInteger < ActiveRecord::Migration
  def self.up
    remove_column :users, :birthday
    add_column :users, :birthday, :integer
  end

  def self.down
    remove_column :users, :birthday
    add_column :users, :birthday, :date
  end
end
