class AddParentCategoryIdToItemCategories < ActiveRecord::Migration
  def self.up
    add_column :item_categories, :parent_category_id, :integer
  end

  def self.down
    remove_column :item_categories, :parent_category_id
  end
end
