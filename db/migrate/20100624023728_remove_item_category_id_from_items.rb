class RemoveItemCategoryIdFromItems < ActiveRecord::Migration
  def self.up
    remove_column :items, :item_category_id
  end

  def self.down
    add_column :items, :item_category_id, :integer
  end
end
