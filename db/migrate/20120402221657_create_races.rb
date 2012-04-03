class CreateRaces < ActiveRecord::Migration
  def self.up
    create_table :races do |t|
      t.references :voting
      t.string :name
      t.integer :grouping

      t.timestamps
    end
  end

  def self.down
    drop_table :races
  end
end
