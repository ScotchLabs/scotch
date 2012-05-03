class CreateVotersJoinTable < ActiveRecord::Migration
  def self.up
    create_table :voters, :id => false do |t|
      t.integer :kaward_id
      t.integer :user_id
    end
  end

  def self.down
  end
end
