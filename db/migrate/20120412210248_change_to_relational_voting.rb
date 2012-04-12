class ChangeToRelationalVoting < ActiveRecord::Migration
  def self.up
    remove_column :nominations, :votes
  end

  def self.down
    add_column :nominations, :votes, :integer, :default => 0
  end
end
