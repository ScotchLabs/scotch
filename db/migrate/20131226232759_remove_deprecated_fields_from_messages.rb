class RemoveDeprecatedFieldsFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :distribution
  end
end
