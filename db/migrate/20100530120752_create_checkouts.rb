class CreateCheckouts < ActiveRecord::Migration
  def self.up
    create_table :checkouts do |t|
      t.integer :group_id
      t.integer :user_id
      t.integer :item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :checkouts
  end
end
