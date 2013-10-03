require 'spec_helper'

describe Show do
  context "mainstage" do
    before do
      @show1 = create(:show, mainstage: false)
      @show2 = create(:show, mainstage: true)
    end

    it "returns only mainstage shows" do
      Show.mainstage.should == [@show2]
    end
  end

  context "current_season" do
    it "shows the current season if there is one" do
      year = Date.today.year
      show1 = create(:show, archive_date: Date.new(year, 9, 1))
      show2 = create(:show, archive_date: Date.new(year, 6, 1))

      Show.current_season.should == [show1]
    end

    it "shows the past season if there is no active season" do
      year = Date.today.year
      show1 = create(:show, archive_date: Date.new(year, 4, 1))
      show2 = create(:show, archive_date: nil)

      Show.current_season.should == [show1]
    end
  end

  context "by year" do
    it "groups shows by year" do
      year = Date.today.year
      show1 = create(:show, archive_date: Date.new(year, 8, 2))
      show2 = create(:show, archive_date: Date.new(year, 3, 5))

      Show.by_year[year].should == [show2]
      Show.by_year[year+1].should == [show1]
    end
  end

  context "auditions?" do
    it "should return false if there are no auditions" do
      show = create(:show)
      
      show.auditions?.should be_false
    end

    it "should return true if there are auditions in the future" do
      show = create(:show)
      create(:audition, owner: show, start_time: Time.now + 1.day, end_time: Time.now + 1.day + 10.minutes)

      show.auditions?.should be_true
    end

    it "should return false if there are only auditions in the past" do
      Timecop.freeze 2.days.ago do
        @show = create(:show)
        create(:audition, owner: @show, start_time: Time.now, end_time: Time.now + 10.minutes)
      end

      @show.auditions?.should be_false
    end
  end

  context "performances" do
    it "returns only performances for the show" do
      show1 = create(:show)
      show2 = create(:show)

      perf1 = create(:performance, owner: show1)
      perf2 = create(:performance, owner: show1)
      perf3 = create(:performance, owner: show2)

      show1.performances.should == [perf1, perf2]
    end
  end

  context "is_public?" do
    it "returns false if the show is not public" do
      show = create(:show, is_public: false)

      show.is_public?.should be_false
    end

    it "returns true if the show is public" do
      show = create(:show, is_public: true)

      show.is_public?.should be_true
    end
  end

  context "tickets_available?" do
    it "returns false if tickets are not released" do
      show = create(:show, tickets_available: false)

      show.tickets_available?.should be_false
    end

    it "returns true if tickets are released" do
      show = create(:show, tickets_available: true)

      show.tickets_available?.should be_true
    end
  end

  context "directors" do
    it "returns an array of directors of a show" do
      show = create(:show)
      director = create(:user)
      position = create(:show_position, group: show, user: director, display_name: 'Director')

      show.directors.should == [director]
    end
  end

  context "show slot" do
    it "returns the show slot with year" do
      Timecop.freeze Date.new(2013, 3, 21) do
        @show = create(:show, slot: 'Carnival', archive_date: Date.today + 1.day)
      end

      @show.show_slot.should == "Carnival 2013"
    end
  end

  context "display directors" do
    it "returns a string with directors of a show" do
      show = create(:show)
      director1 = create(:user, first_name: 'Stephen', last_name: 'Schwartz')
      position1 = create(:show_position, group: show, user: director1, display_name: 'Director')
      director2 = create(:user, first_name: 'Stephen', last_name: 'Sondheim')
      position2 = create(:show_position, role: position1.role, group: show, user: director2, display_name: 'Assistant Director')

      show.display_directors.should == "Stephen Schwartz and Stephen Sondheim"
    end
  end
end
