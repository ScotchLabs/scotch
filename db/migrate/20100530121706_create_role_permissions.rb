class CreateRolePermissions < ActiveRecord::Migration
  def self.up
    create_table :role_permissions do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :role_permissions
  end
end
