class Show < Group

  before_create :set_parent

  def self.manager_role
    roles.where(:name => "Production Staff").first
  end

  private
  def set_parent
    self.parent = Board.directors
  end
end
