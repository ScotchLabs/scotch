class Show < Group

  before_create :set_parent

  private
  def set_parent
    self.parent = Board.directors
  end
end
