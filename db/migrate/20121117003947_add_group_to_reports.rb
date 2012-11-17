class AddGroupToReports < ActiveRecord::Migration
  def change
    add_column :reports, :group_id, :integer

  end
end
