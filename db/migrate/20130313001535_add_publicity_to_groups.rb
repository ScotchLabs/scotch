class AddPublicityToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :is_public, :boolean, default: false
    add_column :groups, :tickets_available, :boolean, default: false
  end
end
