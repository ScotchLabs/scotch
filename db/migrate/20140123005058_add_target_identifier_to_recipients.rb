class AddTargetIdentifierToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :target_identifier, :string
  end
end
