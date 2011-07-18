class SimplifyInventory < ActiveRecord::Migration
  def self.up
    remove_column :checkouts, :opener_id
    remove_column :checkouts, :group_id
    remove_column :checkouts, :due_date
  end

  def self.down
    add_rolumn :checkouts, :opener_id, :integer
    add_rolumn :checkouts, :group_id, :integer
    add_rolumn :checkouts, :due_date, :date
  end
end
