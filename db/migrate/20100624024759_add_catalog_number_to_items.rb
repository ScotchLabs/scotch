class AddCatalogNumberToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :catalog_number, :integer
  end

  def self.down
    remove_column :items, :catalog_number
  end
end
