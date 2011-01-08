class AddUsersToSnsGroup < ActiveRecord::Migration
  def self.up
    User.transaction do
      member_role = Role.member
      sns_group = Group.sns_group
      User.all.each do |user|
        if Position.where(:user_id => user.id).where(:group_id => sns_group.id).count == 0
          p = user.positions.new(:role_id => member_role.id, :display_name => "Member")
          p.group_id = sns_group.id
          if p.save
            puts "Created membership for #{user}"
          else
            puts "Unable to save implicitly created position"
          end
        end
      end
    end
  end

  def self.down
  end
end
