class AddPressDateToVotings < ActiveRecord::Migration
  def self.up
    add_column :votings, :press_date, :date
  end

  def self.down
    remove_column :votings, :press_date
  end
end
