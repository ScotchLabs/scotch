class CreateNominations < ActiveRecord::Migration
  def self.up
    create_table :nominations do |t|
      t.references :race
      t.text :platform
      t.string :tagline
      t.integer :votes
      t.boolean :accepted
      t.boolean :winner
      t.string :write_in_nominee

      t.timestamps
    end
  end

  def self.down
    drop_table :nominations
  end
end
