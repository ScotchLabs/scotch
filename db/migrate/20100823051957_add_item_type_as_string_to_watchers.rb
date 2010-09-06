class AddItemTypeAsStringToWatchers < ActiveRecord::Migration
  def self.up
    add_column :watchers, :item_type, :string
  end

  def self.down
    remove_column :watchers, :item_type
  end
end
