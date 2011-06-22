class AddUploadDocumentPermission < ActiveRecord::Migration
  def self.up
    p = Permission.create(:name => "uploadDocument", 
                      :description => "User can upload a document")

    r = Role.find_by_name("Tech Head")
    r.permissions << p
    r.save

    r = Role.find_by_name("Production Staff")
    r.permissions << p
    r.save
  end

  def self.down
  end
end
