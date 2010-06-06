class Group < ActiveRecord::Base

  has_many :checkouts
  has_many :documents
  has_many :events
  has_many :positions

  belongs_to :parent, :class_name => "Group"

  def self.system_group
    return Group.find(1)
  end

  def permissions_for(user)
    perms = []

    positions.where(:user_id => user.id).each do |p|
      perms << p.role.permissions
    end

    logger.info "group #{self} provides #{user} with permissions #{perms.join(",")}"

    if (parent) then
      return (perms + parent.permissions_for(user)).uniq
    else
      return perms.uniq
    end
  end

  def to_s
    name
  end

end
