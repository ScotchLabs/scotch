class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :target, polymorphic: true
      t.references :source, polymorphic: true
      t.references :subject, polymorphic: true
      t.string :action
      t.string :text
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
