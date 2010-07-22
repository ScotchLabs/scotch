class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.column :name, :string
      t.column :description, :string

      t.timestamps
    end

    add_column :role_permissions, :permission_id, :integer
    remove_column :role_permissions, :name
  end

  def self.down
    drop_table :permissions
    remove_column :role_permissions, :permission_id
    add_column :role_permissions, :name, :string
  end
end
