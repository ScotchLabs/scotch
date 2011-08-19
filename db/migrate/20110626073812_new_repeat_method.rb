class NewRepeatMethod < ActiveRecord::Migration
  def self.up
    remove_column :events, :stop_on_date
    remove_column :events, :stop_after_occurrences
    remove_column :events, :repeat_period
    remove_column :events, :repeat_frequency
    remove_column :events, :repeat_id
    add_column :events, :repeat_next_id, :integer
    add_column :events, :repeat_prev_id, :integer
  end

  def self.down
  end
end
