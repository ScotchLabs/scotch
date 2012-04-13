class ChangeToRelationalVoting < ActiveRecord::Migration
  def self.up
    remove_column :nominations, :votes
    add_column :nominations, :votes_count, :integer, :default => 0
  end

  def self.down
    add_column :nominations, :votes, :integer, :default => 0
    remove_column :nominations, :votes_count
  end
end
