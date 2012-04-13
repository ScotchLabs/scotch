class NominationsController < ApplicationController

  # Nominate someone
  # Must pass a race_id
  def create
    @nomination = Nomination.new(params[:nomination])
    @nomination.votes.build(:user_id => current_user.id)
    if @nomination.save 
      flash[:notice] = "Nomination successful."
    else
      flash[:notice] = "There was a problem with your nomination: #{@nomination.errors}"
    end
    redirect_to @nomination.race.voting
  end

  # elections, nominations - second
  # awards, nominations - vote for a nominee
  # awards, voting - vote for someone
  # if current user is the nominee this is accept
  def vote
  end

  # show a platform
  def show
  end

  # edit a platform
  def edit
  end

  # update a platform
  def update
  end

end
