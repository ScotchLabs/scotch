# == Schema Information
#
# Table name: groups
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  description        :text
#  type               :string(255)
#  parent_id          :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#  short_name         :string(255)
#  archive_date       :date
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#

class Board < Group
  def self.directors
    b = Board.find(2)
    unless b.name == "Board of Directors"
      raise "Did the Board of Directors group change?" 
    end
    return b
  end

  def self.manager_role
    self.roles.where(:name => "Head").first
  end
end
