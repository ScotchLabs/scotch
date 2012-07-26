class AddExtraInfoToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :script_id, :integer

    add_column :groups, :slot, :string

    add_column :groups, :price_with_id, :integer

    add_column :groups, :price_without_id, :integer

    add_column :groups, :location, :string

    add_column :groups, :tech_start, :date

    add_column :groups, :tech_end, :date

  end
end
