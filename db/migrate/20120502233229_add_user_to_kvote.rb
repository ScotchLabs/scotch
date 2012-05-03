class AddUserToKvote < ActiveRecord::Migration
  def self.up
    add_column :kvotes, :user_id, :integer
  end

  def self.down
    remove_column :kvotes, :user_id
  end
end
