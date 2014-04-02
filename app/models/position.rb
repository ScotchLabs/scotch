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

  after_create :add_group_recipient
  before_destroy :remove_group_recipient

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

  protected

  def role_matches_group
    unless role.group_type == group.type
      self.errors.add(:group_id, "isn't aproproate for this role")
    end
  end

  def add_group_recipient
    mg = Mailgunner::Client.new

    mg.add_list_member(group.address, {
      name: user.name,
      address: user.email
    })
  end

  def remove_group_recipient
    mg = Mailgunner::Client.new

    mg.delete_list_member(group.address, user.email)
  end
end
