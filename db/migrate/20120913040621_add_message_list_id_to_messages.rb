class AddMessageListIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :message_list_id, :integer

  end
end
