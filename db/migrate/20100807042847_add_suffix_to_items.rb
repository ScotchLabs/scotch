class AddSuffixToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :suffix, :integer
  end

  def self.down
    remove_column :items, :suffix
  end
end
