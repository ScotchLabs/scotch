class AddCatalogNumberToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :catalog_number, :string
    remove_column :items, :suffix
  end

  def self.down
    add_column :items, :suffix, :integer
    remove_column :items, :catalog_number
  end
end
