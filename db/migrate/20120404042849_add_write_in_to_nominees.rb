class AddWriteInToNominees < ActiveRecord::Migration
  def self.up
    add_column :nominees, :write_in, :string
  end

  def self.down
    remove_column :nominees, :write_in
  end
end
