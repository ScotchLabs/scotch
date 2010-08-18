class AddOpenerIdToCheckouts < ActiveRecord::Migration
  def self.up
    add_column :checkouts, :opener_id, :integer
  end

  def self.down
    remove_column :checkouts, :opener_id
  end
end
