class AddRepeatToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :repeat_id, :integer
    add_column :events, :repeat_frequency, :integer
    add_column :events, :repeat_period, :string
  end

  def self.down
    remove_column :events, :repeat_period
    remove_column :events, :repeat_frequency
    remove_column :events, :repeat_id
  end
end
