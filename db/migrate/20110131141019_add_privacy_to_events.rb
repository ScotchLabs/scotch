class AddPrivacyToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :privacy_type, :string
  end

  def self.down
    remove_column :events, :privacy_type
  end
end
