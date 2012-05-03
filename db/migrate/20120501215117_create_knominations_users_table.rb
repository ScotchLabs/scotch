class CreateKnominationsUsersTable < ActiveRecord::Migration
  def self.up
    create_table :knominations_users, :id => false do |t|
      t.integer :knomination_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :knominations_users
  end
end
