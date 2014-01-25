require 'spec_helper'

describe Recipient do
  context "envelope_recipient" do
    it "retrieves user address" do
      user = create(:user)
      recipient = Recipient.create(target: user)

      recipient.envelope_recipients.should == [user.email]
    end

    it "retrieves group addresses" do
      position = create(:show_position)
      group = position.group
      recipient = Recipient.create(target: group)

      recipient.envelope_recipients.should == [position.user.email]
    end

    it "retrieves active role addresses" do
      position = create(:show_position)
      inactive_group = create(:show, archive_date: Date.today - 5.days)
      position2 = create(:show_position, group: inactive_group,
                        role: position.role)
      role = position.role
      recipient = Recipient.create(target: role)

      recipient.envelope_recipients.should == [position.user.email]
    end

    it "retrieves active position addresses" do
      display_name = 'Production Manager'
      position1 = create(:position, display_name: display_name)
      position2 = create(:position, display_name: display_name,
                          role: position1.role)
      inactive_group = create(:show, archive_date: Date.today - 5.days)
      position3 = create(:show_position, group: inactive_group)
      recipient = Recipient.create(target_identifier: display_name)

      recipient.envelope_recipients.should == [position1.user.email,
                                                position2.user.email]
    end

    it "retrieves group role addresses" do
      group = create(:show)
      role = create(:show_role)
      position1 = create(:position, group: group, role: role)
      position2 = create(:position, group: group, role: role)
      recipient = Recipient.create(target: role, group: group)

      recipient.envelope_recipients.should == [position1.user.email,
                                                position2.user.email]
    end

    it "retrieves group position addresses" do
      display_name = 'Technical Director'
      group = create(:show)
      position1 = create(:show_position, group: group,
                         display_name: display_name)
      position2 = create(:show_position, group: group,
                         display_name: display_name, role: position1.role)
      recipient = Recipient.create(target_identifier: display_name,
                                  group: group)

      recipient.envelope_recipients.should == [position1.user.email,
                                                position2.user.email]
    end
  end
end
