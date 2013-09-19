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
end
