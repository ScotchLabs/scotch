class RemoveTypeFromVotings < ActiveRecord::Migration
  def self.up
    remove_column :votings, :type
  end

  def self.down
    add_column :votings, :type, :string
  end
end
