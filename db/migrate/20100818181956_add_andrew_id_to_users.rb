class AddAndrewIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :andrew_id, :string
  end

  def self.down
    remove_column :users, :andrew_id
  end
end
