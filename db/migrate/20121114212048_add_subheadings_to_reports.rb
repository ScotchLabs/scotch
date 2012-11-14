class AddSubheadingsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :sub_heading, :string
    add_column :reports, :sub_heading2, :string
  end
end
