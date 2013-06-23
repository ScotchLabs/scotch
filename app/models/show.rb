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

  scope :mainstage, where(mainstage: true)

  def self.manager_role
    roles.where(:name => "Production Staff").first
  end

  def self.current_season
    year = Date.today.month > 7 ? Date.today.year : Date.today.year - 1
    where('archive_date BETWEEN ? AND ?', Date.new(year, 8, 1), Date.new(year+1, 5, -1)).order('archive_date ASC')
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

  def progress
    result = []

    if self.performances.count > 0 
      # TODO: add check if strike is happening
      if Time.now > self.performances.last.end_time
        result << {stage: 'Post-Production', color: 'bar-success', amount: 5}
      end

      if Time.now > self.performances.first.start_time
        amount = 20
        amount = 20 - (((self.performances.last.start_time.to_date - Date.today)/(self.performances.last.end_time.to_date - self.performances.first.start_time.to_date))*20).to_i if Time.now < self.performances.last.end_time

        result << {stage: 'Production', color: 'bar-warning', amount: amount}
      end
    end

    if Time.now > self.tech_start
      amount = 30
      amount = 30 - (((self.tech_end.to_date - Date.today)/(self.tech_end.to_date - self.tech_start.to_date))*30).to_i if Time.now < self.tech_end
      result << {stage: 'TECH WEEK', color: 'bar-danger', amount: amount}
    end

    amount = 45
    if !self.performances.empty? && Time.now < self.performances.first.start_time
      amount = 45 - (((self.tech_start.to_date - Date.today)/(self.tech_start.to_date - self.created_at.to_date))*45).to_i
    elsif Date.today - self.created_at.to_date < 45
      amount = (Date.today - self.created_at.to_date).to_i
    end

    if self.board_preview && Date.today == self.board_preview.start_time.to_date
      result << {stage: 'Board Preview', color: 'bar-info', amount: amount}
    elsif self.auditions?
      result << {stage: 'Board Preview', color: 'bar-info', amount: amount}
    else
      result << {stage: 'Pre-Production', color: 'bar-info', amount: amount}
    end

    result.reverse
  end
  
  private
  def set_parent
    self.parent = Board.directors
  end
end
