class AddStopConditionToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :stop_after_occurrences, :integer
    add_column :events, :stop_on_date, :string
  end

  def self.down
    remove_column :events, :stop_on_date
    remove_column :events, :stop_after_occurrences
  end
end
