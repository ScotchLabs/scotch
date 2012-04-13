class NominationsController < ApplicationController

  # Nominate someone
  # Must pass a race_id
  def create
    @nomination = Nomination.new(params[:nomination])
    @race = @nomination.race
    @voting = @race.voting

    @nomination.votes.build(:user_id => current_user.id)
    if @nomination.save 
      flash[:notice] = "Nomination successful."
    else
      flash[:notice] = "There was a problem with your nomination: #{@nomination.errors.full_messages.join("; ")}"
    end
    redirect_to @voting
  end

  # elections, nominations - second
  # awards, nominations - vote for a nominee
  # awards, voting - vote for someone
  # if current user is the nominee this is accept
  def vote
    @nomination = Nomination.find(params[:id])
    @race = @nomination.race
    @voting = @race.voting

    @vote = @nomination.votes.build(:user_id => current_user.id)
    if @vote.save
      flash[:notice] = "You've voted for #{@nomination} for #{@race}."
    else
      flash[:notice] = "There was an issue recording your vote: #{@vote.errors.full_messages.join("; ")}"
    end
    redirect_to @voting
  end

  # show a platform
  def show
    @nomination = Nomination.find(params[:id])
    @group = @nomination.voting.group
  end

  # edit a platform
  def edit
    @nomination = Nomination.find(params[:id])
    @group = @nomination.voting.group
  end

  # update a platform
  def update
    @nomination = Nomination.find(params[:id])
    @group = @nomination.voting.group
    if @nomination.update_attributes(params[:nomination])
        redirect_to(@nomination, :notice => 'Platform was successfully updated.')
    else
      render :action => "edit"
    end
  end

end
