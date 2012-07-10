class AddRepeatAndRemoveOldToEvents < ActiveRecord::Migration
  def change
    remove_column :events, :repeat_id
    remove_column :events, :all_day
    remove_column :events, :privacy_type
    add_column :events, :session, :string
  end
end
