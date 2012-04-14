class AddWriteInAvailableToRaces < ActiveRecord::Migration
  def self.up
    add_column :races, :write_in_available, :boolean
  end

  def self.down
    remove_column :races, :write_in_available
  end
end
