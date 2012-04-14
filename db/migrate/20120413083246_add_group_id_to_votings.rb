class AddGroupIdToVotings < ActiveRecord::Migration
  def self.up
    add_column :votings, :group_id, :integer, :null => false
  end

  def self.down
    remove_column :votings, :group_id
  end
end
