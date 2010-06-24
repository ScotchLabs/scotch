class AddItemSubcategoryIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :item_subcategory_id, :integer
  end

  def self.down
    remove_column :items, :item_subcategory_id
  end
end
