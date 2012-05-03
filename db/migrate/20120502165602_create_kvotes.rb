class CreateKvotes < ActiveRecord::Migration
  def self.up
    create_table :kvotes do |t|
      t.integer :knomination_id
      t.boolean :positive
      t.string :stage

      t.timestamps
    end
  end

  def self.down
    drop_table :kvotes
  end
end
