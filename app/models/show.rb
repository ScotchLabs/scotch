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

  scope :mainstage, where(mainstage: true)

  def self.manager_role
    roles.where(:name => "Production Staff").first
  end

  def self.current_season
    year = Date.today.month > 8 ? Date.today.year : Date.today.year - 1
    result = where('archive_date BETWEEN ? AND ?', Date.new(year, 8, 1), Date.new(year+1, 5, -1)).order('archive_date ASC')
    
    unless result.count > 0
      year = year - 1
      result = where('archive_date BETWEEN ? AND ?', Date.new(year, 8, 1), Date.new(year+1, 5, -1)).order('archive_date ASC')
    end

    result
  end

  def self.by_year
    archived.order('archive_date ASC').group_by do |s|
      s.archive_date.month > 7 ? s.archive_date.year + 1 : s.archive_date.year
    end
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

  def performances
    self.events.where(event_type: 'show')
  end

  def is_public?
    self.is_public
  end

  def tickets_available?
    self.tickets_available
  end

  def directors
    self.positions.where(display_name: ['Director', 'Creative Director', 'Assistant Director', 'Music Director', 'Assistant Music Director']).sort.map {|p| p.user}
  end

  def show_slot
    (self.slot || "") + " " + (self.archive_date.try(:year) || Date.current.year).to_s
  end

  def display_directors
    result = self.directors.map {|u| u.name}
    
    if result.size > 1
      result[-1] = 'and ' + result[-1]

      if result.size < 3
        return result.join(' ')
      else
        return result.join(', ')
      end
    end

    result[0]
  end
end
