class DashboardController < ApplicationController
  def root
    redirect_to dashboard_index_path
  end
  
  def index
    unless current_user.valid?
      flash[:notice] = "Sorry, but we need you to fill out some profile information before continuing."
      redirect_to edit_user_path(current_user)
    end
    
    @events = current_user.attended_events.future
  end

  def calendar
    @myevents = current_user.user_events
    @mygroups = current_user.groups.active.uniq
    @activeshows = Show.active - @mygroups
    @activegroups = Group.active - @activeshows - @mygroups
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @myevents }
      format.ics do 
        ical = new_ical
        @myevents.each do |event|
          ical.add_event(event.to_ical_event)
        end
        render :text => ical.to_ical, :status => 200
      end
    end
  end

  def search
    @users = User.search(params[:q]).sort
    @shows = Show.search(params[:q]).sort
    @groups = Group.search(params[:q]).where("type != 'Show'").sort

    respond_to do |format|
      format.html
      format.json
    end
  end

  private
  def new_ical
    ical = Icalendar::Calendar.new
    ical.product_id = "-//scotch.snstheatre.org//iCal 1.0//EN"
    ical.custom_property("X-WR-TIMEZONE;VALUE=TEXT", "US/Eastern")
    return ical
  end
end
