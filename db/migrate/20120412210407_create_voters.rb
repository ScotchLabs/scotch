class CreateVoters < ActiveRecord::Migration
  def self.up
    create_table :voters do |t|
      t.integer :user_id
      t.integer :voting_id
      t.integer :votes_count
      t.boolean :has_voted, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :voters
  end
end
