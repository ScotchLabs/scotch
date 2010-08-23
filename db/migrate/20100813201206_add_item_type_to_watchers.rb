class AddItemTypeToWatchers < ActiveRecord::Migration
  def self.up
    add_column :watchers, :item_type, :integer
  end

  def self.down
    remove_column :watchers, :item_type
  end
end
