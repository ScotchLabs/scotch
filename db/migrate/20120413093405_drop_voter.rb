class DropVoter < ActiveRecord::Migration
  def self.up
    drop_table :voters
    remove_column :votes, :voter_id
    add_column :votes, :user_id, :integer
  end

  def self.down
  end
end
