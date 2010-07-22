class AddBirthmonthToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birthmonth, :integer
  end

  def self.down
    remove_column :users, :birthmonth
  end
end
