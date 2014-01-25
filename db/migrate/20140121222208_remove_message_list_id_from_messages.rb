class RemoveMessageListIdFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :message_list_id
  end
end
