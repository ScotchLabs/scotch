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
