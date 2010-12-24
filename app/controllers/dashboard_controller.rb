class DashboardController < ApplicationController
  def index
    unless current_user.valid?
      flash[:notice] = "Sorry, but we need you to fill out some profile information before continuing."
      redirect_to edit_user_path(current_user)
    end
  end

  def calendar
    @events = current_user.user_events

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
      format.ics do 
        ical = new_ical
        @events.each do |event|
          ical.add_event(event.to_ical_event)
        end
        render :text => ical.to_ical, :status => 200
      end
    end
  end

  def search
    @results = 
      User.with_query(params[:q]).limit(20) +
      Group.with_query(params[:q]).limit(20) +
      Item.with_query(params[:q]).limit(20)

    @results = @results.sort_by{|i| i.updated_at}.reverse
  end

  private
  def new_ical
    ical = Icalendar::Calendar.new
    ical.product_id = "-//scotch.snstheatre.org//iCal 1.0//EN"
    ical.custom_property("X-WR-TIMEZONE;VALUE=TEXT", "US/Eastern")
    return ical
  end
end
