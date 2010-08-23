class RemoveItemTypeFromWatchers < ActiveRecord::Migration
  def self.up
    remove_column :watchers, :item_type
  end

  def self.down
    add_column :watchers, :item_type, :integer
  end
end
