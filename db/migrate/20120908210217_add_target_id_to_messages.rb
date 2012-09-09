class AddTargetIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :target_id, :integer

  end
end
