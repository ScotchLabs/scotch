class CreatePositions < ActiveRecord::Migration
  def self.up
    create_table :positions do |t|
      t.integer :group_id
      t.integer :role_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :positions
  end
end
