class AddPositionDisplayName < ActiveRecord::Migration
  def self.up
    add_column :positions, :display_name, :string
  end

  def self.down
    remove_column :positions, :display_name
  end
end
