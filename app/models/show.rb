class Show < Group

  before_create :set_parent

  private
  def set_parent
    logger.info "setting parent to #{Board.directors}"
    self.parent = Board.directors
  end
end
