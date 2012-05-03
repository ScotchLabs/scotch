class CreateNominatorsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :nominators, :id => false do |t|
      t.integer :knomination_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :nominators
  end
end
