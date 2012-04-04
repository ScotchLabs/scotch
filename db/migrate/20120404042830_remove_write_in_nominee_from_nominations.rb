class RemoveWriteInNomineeFromNominations < ActiveRecord::Migration
  def self.up
    remove_column :nominations, :write_in_nominee
  end

  def self.down
    add_column :nominations, :write_in_nominee, :string
  end
end
