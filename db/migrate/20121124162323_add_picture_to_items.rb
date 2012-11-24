class AddPictureToItems < ActiveRecord::Migration
  def up
    add_attachment :items, :picture
  end

  def down
    remove_attachment :items, :picture
  end
end
