class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :name
      t.string :location
      t.text :description
      t.integer :item_category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
