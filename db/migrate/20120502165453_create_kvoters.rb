class CreateKvoters < ActiveRecord::Migration
  def self.up
    create_table :kvoters do |t|
      t.integer :user_id
      t.integer :kudo_id
      t.boolean :has_voted

      t.timestamps
    end
  end

  def self.down
    drop_table :kvoters
  end
end
