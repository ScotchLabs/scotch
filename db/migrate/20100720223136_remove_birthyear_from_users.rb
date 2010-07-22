class RemoveBirthyearFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :birthyear
  end

  def self.down
    add_column :users, :birthyear, :integer
  end
end
