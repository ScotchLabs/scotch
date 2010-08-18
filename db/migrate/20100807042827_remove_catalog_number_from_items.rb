class RemoveCatalogNumberFromItems < ActiveRecord::Migration
  def self.up
    remove_column :items, :catalog_number
  end

  def self.down
    add_column :items, :catalog_number, :string
  end
end
