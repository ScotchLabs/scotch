require 'spec_helper'

describe Group do
  it { should belong_to(:parent) }
  it { should belong_to(:script) }

  it { should have_many(:documents).dependent(:destroy) }
  it { should have_many(:folders).dependent(:destroy) }
  it { should have_many(:positions).dependent(:destroy) }
  it { should have_many(:users).through(:positions) }
  it { should have_many(:members).through(:positions) }
  it { should have_many(:ticket_reservations).through(:events) }

  it { should allow_value('a').for(:short_name) }
  it { should allow_value('abcdefghijklabcdabcd').for(:short_name) }
  it { should_not allow_value(nil).for(:short_name) }
  it { should_not allow_value('').for(:short_name) }

  context "short_name" do
    it "should be unique" do
      group1 = create(:group, short_name: 'short')
      group2 = build(:group, short_name: 'short')

      group2.valid?.should be_false
    end
  end

  context "with active/inactive groups" do
    before do
      @group1 = create(:group, archive_date: 12.days.ago)
      @group2 = create(:group, archive_date: nil)
    end

    context "active" do
      it "returns only active groups" do
        Group.active.should == [@group2]
      end
    end

    context "archived" do
      it "returns only archived groups" do
        Group.archived.should == [@group1]
      end
    end
  end

  context "with public/private and ticketed groups" do
    before do
      @group1 = create(:group, is_public: false)
      @group2 = create(:group, is_public: true)
      @group3 = create(:group, is_public: true, tickets_available: true)
    end

    context "public" do
      it "returns only public groups" do
        Group.public.should == [@group2, @group3]
      end
    end

    context "tickets_available" do
      it "returns only groups released to ScotchBox" do
        Group.tickets_available.should == [@group3]
      end
    end
  end

  context "archived?" do
    it "returns true if archived" do
      group = create(:group, archive_date: 5.days.ago)

      group.archived?.should be_true
    end

    it "returns false if active" do
      group = create(:group, archive_date: nil)

      group.archived?.should be_false
    end
  end

  context "active?" do
    it "returns true if active" do
      group = create(:group, archive_date: nil)

      group.active?.should be_true
    end

    it "returns false if archived" do
      group = create(:group, archive_date: 5.days.ago)

      group.active?.should be_false
    end
  end
end
