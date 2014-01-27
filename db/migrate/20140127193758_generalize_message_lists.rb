class GeneralizeMessageLists < ActiveRecord::Migration
  def up
    remove_column :message_lists, :address
    remove_column :message_lists, :distribution
    remove_column :message_lists, :entire_group
    remove_column :message_lists, :security
  end

  def down
    add_column :message_lists, :address, :string
    add_column :message_lists, :distribution, :string, default: 'email'
    add_column :message_lists, :entire_group, :boolean, default: false
    add_column :message_lists, :security, :string
  end
end
