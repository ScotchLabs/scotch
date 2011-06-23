class Show < Group

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
  
  private
  def set_parent
    self.parent = Board.directors
  end
end
