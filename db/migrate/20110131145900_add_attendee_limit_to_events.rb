class AddAttendeeLimitToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :attendee_limit, :integer
  end

  def self.down
    remove_column :events, :attendee_limit
  end
end
