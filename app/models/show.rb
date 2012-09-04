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

class Show < Group
  
  LOCATIONS = ['McConomy Auditorium', 'Rangos Auditorium', 'Peter/Wright/McKenna', 'UC Connan']

  before_create :set_parent

  def self.manager_role
    roles.where(:name => "Production Staff").first
  end
  
  def calendar_positions
    a=super
    pos = positions.map{|e| e.simple}.compact
    a.push(:name=>"Cast",:positions=>pos.select{|e| e[:role]=="Cast"}) unless pos.select{|e| e[:role]=="Cast"}.empty?
    a.push(:name=>"Production Staff",:positions=>pos.select{|e| e[:role]=="Production Staff"}) unless pos.select{|e| e[:role]=="Production Staff"}.empty?
    a.push(:name=>"Tech Heads",:positions=>pos.select{|e| e[:role]=="Tech Head"}) unless pos.select{|e| e[:role]=="Tech Head"}.empty?
    crews = pos.select{|e| e[:role]=~/Crew/}.map{|e| e[:position]}.uniq
    for crew in crews
      a.push(:name=>"#{crew}",:positions=>pos.select{|e| e[:position]==crew})
    end
    a
  end
  
  def tech_interest
    self.events.where{title =~ "%tech%interest%"}.first
  end
  
  def board_preview
    self.events.where{title =~ "%board%preview%"}.first
  end

  def auditions?
    self.events.future.auditions.count > 0
  end
  
  private
  def set_parent
    self.parent = Board.directors
  end
end
