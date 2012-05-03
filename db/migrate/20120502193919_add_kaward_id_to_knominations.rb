class AddKawardIdToKnominations < ActiveRecord::Migration
  def self.up
    add_column :knominations, :kaward_id, :integer
  end

  def self.down
    remove_column :knominations, :kaward_id
  end
end
