class Role < ActiveRecord::Base
  has_many :role_permissions
  has_many :permissions, :through => :role_permissions

  validates_inclusion_of :group_type, :in => ["Group", "Show", "Board"], :message => "is not included in the list: ['Group', 'Show', 'Board']"
  validates_uniqueness_of :name, :scope => :group_type

  # Sort based on the number of permissions
  def <=>(other)
    permissions.count <=> other.permissions.count
  end

  def to_s
    name
  end

  # Is this a crew role, for use with the adminCrew position
  def crew?
    name == "Crew"
  end

  # Canonical crew role
  def self.crew
    self.find_by_name("Crew")
  end
end
