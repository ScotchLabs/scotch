class RemoveDocumentIdFromReports < ActiveRecord::Migration
  def up
    remove_column :reports, :document_id
  end

  def down
    add_column :reports, :document_id, :integer
  end
end
