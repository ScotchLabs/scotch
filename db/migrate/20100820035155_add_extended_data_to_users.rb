class AddExtendedDataToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :majors, :string
    add_column :users, :minors, :string
    add_column :users, :other_activities, :string
  end

  def self.down
    remove_column :users, :other_activities
    remove_column :users, :minors
    remove_column :users, :majors
  end
end
