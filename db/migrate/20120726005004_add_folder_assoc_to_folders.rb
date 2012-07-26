class AddFolderAssocToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :folder_id, :integer

  end
end
