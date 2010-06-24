class CreateItemSubcategories < ActiveRecord::Migration
  def self.up
    create_table :item_subcategories do |t|
      t.string :name
      t.integer :infix
      t.integer :item_category_id

      t.timestamps
    end
  end

  def self.down
    drop_table :item_subcategories
  end
end
