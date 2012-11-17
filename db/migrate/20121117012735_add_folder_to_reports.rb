class AddFolderToReports < ActiveRecord::Migration
  def change
    add_column :reports, :folder_id, :integer

  end
end
