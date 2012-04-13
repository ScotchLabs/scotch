class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :voter_id
      t.integer :nomination_id

      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
