class AddEmailNotificationsSetting < ActiveRecord::Migration
  def self.up
    add_column :users, :email_notifications, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :users, :email_notifications
  end
end
