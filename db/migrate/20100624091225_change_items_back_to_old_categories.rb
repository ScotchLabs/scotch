class ChangeItemsBackToOldCategories < ActiveRecord::Migration
  def self.up
   # remove_column :items, :item_subcategory_id
   # add_column :items, :item_category_id, :integer
  end

  def self.down
   # remove_column :items, :item_category_id
   # add_column :item, :item_subcategory_id
  end
end
