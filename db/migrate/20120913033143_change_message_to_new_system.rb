class ChangeMessageToNewSystem < ActiveRecord::Migration
  def change
    remove_column :messages, :user_id
    remove_column :messages, :target_id
    remove_column :messages, :priority
    remove_column :messages, :message_thread_id
    
    add_column :messages, :subject, :string
    add_column :messages, :distribution, :string, default: 'scotch'
  end
end
