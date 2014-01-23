class GeneralizeRecipients < ActiveRecord::Migration
  def change
    remove_column :recipients, :message_list_id
    remove_column :recipients, :message_id
    remove_column :recipients, :user_id

    add_column :recipients, :owner_id, :integer
    add_column :recipients, :owner_type, :string
    add_column :recipients, :group_id, :integer
    add_column :recipients, :target_id, :integer
    add_column :recipients, :target_type, :string
  end
end
