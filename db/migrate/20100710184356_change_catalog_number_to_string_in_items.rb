class ChangeCatalogNumberToStringInItems < ActiveRecord::Migration
  def self.up
    remove_column :items, :catalog_number
    add_column :items, :catalog_number, :string
  end

  def self.down
    remove_column :items, :catalog_number
    add_column :items, :catalog_number, :integer
  end
end
