class RemoveOldInventory < ActiveRecord::Migration
  def change
    drop_table :item_categories
    drop_table :items
  end
end
