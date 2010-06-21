class Board < Group
  def self.directors
    b = Board.find(2)

    unless b.name == "Board of Directors"
      raise "Did the Board of Directors group change?" 
    end

    return b
  end
end
