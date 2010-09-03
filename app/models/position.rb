class Position < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  belongs_to :group

  validates_presence_of :user_id, :role_id, :group_id

  default_scope order("created_at DESC")

  attr_protected :group_id

  validate :role_matches_group

  after_create :create_watcher

  def to_s
    display_name
  end

  def <=>(other)
    gsort = group<=>other.group
    if gsort == 0
      role <=> other.role || display_name <=> other.display_name
    else
      return gsort
    end
  end

  protected

  def role_matches_group
    unless role.group_type == group.class.name
      errors[:role] << "isn't aproproate for this group"
    end
  end

  def create_watcher
    if Watcher.where(:user_id => user.id).where(:item_id => group.id).where(:item_type => "Group").count == 0
      w = Watcher.new
      w.user = user
      w.item = group
      w.save or logger.warn "Unable to save implicitly created watcher"
    end
  end

end
