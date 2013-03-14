class AddMainstageToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :mainstage, :boolean, default: false
  end
end
