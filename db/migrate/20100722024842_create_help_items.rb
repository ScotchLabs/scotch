class CreateHelpItems < ActiveRecord::Migration
  def self.up
    create_table :help_items do |t|
      t.string :display_text
      t.string :name
      t.string :anchor
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :help_items
  end
end
