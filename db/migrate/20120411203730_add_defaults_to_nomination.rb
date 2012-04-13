class AddDefaultsToNomination < ActiveRecord::Migration
  def self.up
    change_column :nominations, :accepted, :boolean, :default => false
    change_column :nominations, :winner, :boolean, :default => false
  end

  def self.down
    change_column :nominations, :accepted, :boolean
    change_column :nominations, :winner, :boolean
  end
end
