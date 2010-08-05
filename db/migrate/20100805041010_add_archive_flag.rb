class AddArchiveFlag < ActiveRecord::Migration
  def self.up
    add_column :groups, :archive_date, :date
  end

  def self.down
    remove_column :groups, :archive_date
  end
end
