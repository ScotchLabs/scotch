class RepeatEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :repeat_id, :integer
    remove_column :events, :repeat_prev_id
    remove_column :events, :repeat_next_id
  end

  def self.down
    remove_column :events, :repeat_id
    add_column :events, :repeat_next_id, :integer
    add_column :events, :repeat_prev_id, :integer
  end
end
