class RenameAndrewId < ActiveRecord::Migration
  def self.up
    rename_column :users, :andrew_id, :andrewid
  end

  def self.down
    rename_column :users, :andrewid, :andrew_id
  end
end
