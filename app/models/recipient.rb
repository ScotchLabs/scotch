class Recipient < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :group
  belongs_to :target, polymorphic: true

  def envelope_recipients
    if target_identifier
      if group
        Position.where(group_id: group.id, display_name: target_identifier)
        .includes(:user).map { |p| p.user.email }
      else
        Position.where(group_id: Group.active, display_name: target_identifier)
        .includes(:user).map { |p| p.user.email }
      end
    elsif target.is_a? User
      [target.email]
    elsif target.is_a? Group
      target.members.pluck(:email)
    elsif target.is_a? Role
      if group
        Position.where(group_id: group, role_id: target)
        .includes(:user).map { |p| p.user.email }
      else
        Position.where(group_id: Group.active, role_id: target)
        .includes(:user).map { |p| p.user.email }
      end
    end
  end
end
