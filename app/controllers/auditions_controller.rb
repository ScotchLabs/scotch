class AuditionsController < ApplicationController
  layout 'group'

  before_filter :get_audition, except: [:index, :new, :create]

  def index
    @auditions = @group.events.auditions.group_by{ |a| a.start_time.wday}

    @auditioners = []

    @group.events.auditions.each do |a|
      @auditioners << a.users.first.andrewid if a.users.count > 0
    end
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def show
  end

  def destroy
  end

  def signup
    if @audition.event_attendees.count > 0
      if @audition.users.first == current_user
        @audition.event_attendees.clear
        redirect_to group_auditions_path(@audition.owner), notice: 'Audition Cancelled'
      else
        redirect_to group_auditions_path(@audition.owner), error: 'This slot is full'
      end
    else
      @audition.attendees = current_user
      @audition.save
      redirect_to group_auditions_path(@audition.owner), notice: 'Signed up for audition!'
    end
  end

  def get_audition
    if params[:id]
      @audition = Event.auditions.find(params[:id])
    end
  end
end
