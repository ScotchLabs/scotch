class SimplifyInventory < ActiveRecord::Migration
  def self.up
    remove_column :checkouts, :opener_id
    remove_column :checkouts, :group_id
    remove_column :checkouts, :due_date
  end

  def self.down
    add_column :checkouts, :opener_id, :integer
    add_column :checkouts, :group_id, :integer
    add_column :checkouts, :due_date, :date
  end
end
