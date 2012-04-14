class MakeDefaultVotesZero < ActiveRecord::Migration
  def self.up
    change_column :nominations, :votes, :integer, :default => 0
  end

  def self.down
    change_column :nominations, :votes, :integer
  end
end
