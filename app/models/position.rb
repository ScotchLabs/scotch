# == Schema Information
#
# Table name: positions
#
#  id           :integer(4)      not null, primary key
#  group_id     :integer(4)
#  role_id      :integer(4)
#  user_id      :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  display_name :string(255)
#

class Position < ActiveRecord::Base

  belongs_to :user
  belongs_to :role
  belongs_to :group

  DIRECTORS = ['Director', 'Creative Director', 'Assistant Director',
    'Music Director', 'Assistant Music Director']

  validates_presence_of :user_id, :role_id, :group_id, :display_name

  attr_protected :group_id

  #FIXME: This is a stupid workaround for SimpleForm
  attr_accessor :andrewid

  validate :role_matches_group

  after_create :add_recipients
  before_destroy :remove_recipients

  scope :active, includes(:group).where('groups.archive_date IS NULL')

  def to_s
    display_name
  end

  def <=>(other)
    gsort = group<=>other.group
    if gsort == 0
      if DIRECTORS.include?(display_name) && DIRECTORS.include?(other.display_name)
        return DIRECTORS.index(display_name) <=> DIRECTORS.index(other.display_name)
      end
      return role <=> other.role unless (role <=> other.role) == 0
      return display_name.gsub("Assistant ","") <=> other.display_name.gsub("Assistant ","") unless (display_name.gsub("Assistant ","") <=> other.display_name.gsub("Assistant ","")) == 0
      return other.display_name  <=> display_name
    else
      return gsort
    end
  end
  
  def simple
    return nil if user.nil?
    {:position=>display_name, :role=>Role.find(role_id).name,:andrewid=>user.andrewid,:user_name=>user.name, :user_email=>user.email, :id => user.id,
      :type => 'User'}
  end

  def user_name
    user.try(:name)
  end

  def to
    if group
      "\"#{group.name} #{display_name}\"<#{address}>"
    else
      "\"#{display_name}\"<#{address}>"
    end
  end

  def address
    if group
      "#{group.short_name}+#{display_name.downcase.gsub(' ', '')}@#{ENV['MAILGUN_DOMAIN']}"
    else
      global_address
    end
  end

  def global_address
    "#{display_name.downcase.gsub(' ', '')}@#{ENV['MAILGUN_DOMAIN']}"
  end

  def add_recipients
    # TODO: Create Role mailing lists and global position
    mg = Mailgunner::Client.new

    mg.add_list_member(group.address, {
      name: user.name,
      address: user.email
    })

    mg.add_list({
      name: display_name,
      address: global_address
    })

    mg.add_list_member(global_address, {
      name: user_name,
      address: user.email
    })

    mg.add_list({
      name: "#{group.name} #{display_name}",
      address: address
    })

    mg.add_list_member(address, {
      name: user_name,
      address: user.email
    })

    mg.add_list({
      name: role.name,
      address: role.global_address
    })

    mg.add_list_member(role.global_address, {
      name: user_name,
      address: user.email
    })

    mg.add_list({
      name: "#{group.name} #{role.name}",
      address: "#{group.short_name}+#{role.global_address}"
    })

    mg.add_list_member("#{group.short_name}+#{role.global_address}", {
      name: user_name,
      address: user.email
    })
  end

  def remove_recipients
    mg = Mailgunner::Client.new

    if user.positions.active.where(group_id: group.id).count <= 1
      mg.delete_list_member(group.address, user.email)
    end

    if user.positions.active.where(group_id: group.id, display_name: display_name).count <= 1
      mg.delete_list_member(address, user.email)
    end

    if user.positions.active.where(display_name: display_name).count <= 1
      mg.delete_list_member(global_address, user.email)
    end

    if user.positions.active.where(group_id: group.id, role_id: role.id).count <= 1
      mg.delete_list_member("#{group.short_name}+#{role.global_address}", user.email)
    end

    if user.positions.active.where(role_id: role.id).count <= 1
      mg.delete_list_member(role.global_address, user.email)
    end
  end

  protected

  def role_matches_group
    unless role.group_type == group.type
      self.errors.add(:group_id, "isn't aproproate for this role")
    end
  end
end
