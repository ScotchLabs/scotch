class AddWritersToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :writers, :string
  end
end
