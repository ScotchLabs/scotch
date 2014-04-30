class NominationsController < ApplicationController
  prepend_before_filter :locate_nomination, :except => [:create]
  prepend_before_filter :locate_group_race_voting, :only => [:create]

  before_filter :only => [:edit, :update, :destroy] do
    unless @nomination.users.include? current_user
      require_permission "adminElection"
    end
  end

  # Nominate someone
  # Must pass a race_id
  def create
    params[:nomination][:nominees_attributes].each do |k, v|
      v[:user_id] = User.find_by_andrewid(v[:user_id]).id
    end

    @nomination = Nomination.create(params[:nomination])
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
    @vote = @nomination.votes.build(:user_id => current_user.id)
    if @vote.save
      if @nomination.nominees.where(:user_id => current_user.id).count > 0
        @vote.nomination.update_attribute(:accepted, true)
        flash[:notice] = "You've accepted your nomination for #{@race}."
      else
        flash[:notice] = "You've voted for #{@nomination}."
      end
    else
      flash[:notice] = "There was an issue recording your vote: #{@vote.errors.full_messages.join("; ")}"
    end
    redirect_to @voting
  end

  # show a platform
  def show
  end

  # edit a platform
  def edit
  end

  # update a platform
  def update
    if @nomination.update_attributes(params[:nomination])
        redirect_to(@nomination, :notice => 'Platform was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @nomination.destroy

    redirect_to @voting
  end

  protected

  def locate_nomination
    @nomination = Nomination.find(params[:id])
    @race = @nomination.race
    @voting = @race.voting
    @group = @voting.group
  end
  
  def locate_group_race_voting
    @race = Race.find(params[:nomination][:race_id])
    @voting = @race.voting
    @group = @race.voting.group
  end

end
