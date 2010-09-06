class CreateWatchers < ActiveRecord::Migration
  def self.up
    create_table :watchers do |t|
      t.integer :user_id
      t.integer :item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :watchers
  end
end
