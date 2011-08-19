class AddRecipientsToFeedposts < ActiveRecord::Migration
  def self.up
    add_column :feedposts, :recipient_ids, :text
  end

  def self.down
    remove_column :feedposts, :recipient_ids
  end
end
