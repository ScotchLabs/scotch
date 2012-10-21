class CreateDependencies < ActiveRecord::Migration
  def change
    create_table :dependencies do |t|
      t.integer :task_id
      t.integer :prequisite_id

      t.timestamps
    end
  end
end
