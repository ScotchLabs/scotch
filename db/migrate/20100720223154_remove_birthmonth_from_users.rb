class RemoveBirthmonthFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :birthmonth
  end

  def self.down
    add_column :users, :birthmonth
  end
end
