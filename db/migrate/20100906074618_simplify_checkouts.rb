class SimplifyCheckouts < ActiveRecord::Migration
  def self.up
    drop_table :checkout_events
    add_column :checkouts, :checkout_date, :date
    add_column :checkouts, :checkin_date, :date
    add_column :checkouts, :due_date, :date
    add_column :checkouts, :notes, :text
  end

  def self.down
  end
end
