class AddVotingTypeToVotings < ActiveRecord::Migration
  def self.up
    add_column :votings, :voting_type, :string
  end

  def self.down
    remove_column :votings, :voting_type
  end
end
