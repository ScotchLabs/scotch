require 'spec_helper'

describe User do
  it { should have_many(:positions).dependent(:destroy) }
  it { should have_many(:groups).through(:positions) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:andrewid) }

  it { should allow_value('3055555555').for(:phone) }
  it { should allow_value('305-555-5555').for(:phone) }
  it { should allow_value('(305) 555-5555').for(:phone) }
  it { should allow_value('305 555 5555').for(:phone) }
  it { should allow_value(nil).for(:phone) }
  it { should allow_value('').for(:phone) }
  it { should_not allow_value('305555000').for(:phone) }

  it { should allow_value('1111').for(:smc) }
  it { should allow_value('9999').for(:smc) }
  it { should allow_value(nil).for(:smc) }
  it { should allow_value('').for(:smc) }
  it { should_not allow_value('111').for(:smc) }
  it { should_not allow_value('11111').for(:smc) }
  it { should_not allow_value('ABCD').for(:smc) }

  it { should allow_value('Morewood E 512').for(:residence) }
  it { should allow_value('PoD').for(:residence) }
  it { should allow_value(nil).for(:residence) }
  it { should allow_value('').for(:residence) }

  it { should allow_value('2015').for(:graduation_year) }
  it { should allow_value(nil).for(:graduation_year) }
  it { should allow_value('').for(:graduation_year) }
  it { should_not allow_value('201').for(:graduation_year) }
  it { should_not allow_value('20156').for(:graduation_year) }
  it { should_not allow_value('ABCD').for(:graduation_year) }

  it { should allow_value('DC').for(:home_college) }
  it { should allow_value(nil).for(:home_college) }
  it { should allow_value('').for(:home_college) }
  it { should_not allow_value('NOT').for(:home_college) }

  context "active_member?" do
    it "returns true if user is active" do
      user = create(:user)
      position = create(:show_position, user: user)

      user.active_member?.should be_true
    end

    it "returns false if user is inactive" do
      user = create(:user)
      position = create(:show_position, user: user, created_at: Time.now - 9.months)

      user.active_member?.should be_false
    end
  end

  context "incomplete_record?" do
    it "returns false if record is complete" do
      user = create(:user)

      user.incomplete_record?.should be_false
    end

    it "returns true if record is incomplete" do
      user = create(:user, home_college: nil)

      user.incomplete_record?.should be_true
    end
  end

  context "age" do
    it "returns the user's age" do
      user = create(:user, birthday: 18.years.ago)

      user.age.should == 18
    end

    it "returns nil if birthday is not set" do
      user = create(:user, birthday: nil)

      user.age.should be_nil
    end
  end

  context "name" do
    it "returns the user's full name" do
      user = create(:user, first_name: 'Stephen', last_name: 'Sondheim')

      user.name.should == 'Stephen Sondheim'
    end
  end
end

