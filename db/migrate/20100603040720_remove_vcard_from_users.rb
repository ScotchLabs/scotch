class RemoveVcardFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :vcard
    add_column :users, :phone, :string
    add_column :users, :home_college, :string
    add_column :users, :smc, :string
    add_column :users, :graduation_year, :string
    add_column :users, :residence, :string
    add_column :users, :gender, :string
  end

  def self.down
  end
end
