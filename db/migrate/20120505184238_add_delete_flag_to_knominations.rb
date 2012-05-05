class AddDeleteFlagToKnominations < ActiveRecord::Migration
  def self.up
    add_column :knominations, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :knominations, :deleted
  end
end
