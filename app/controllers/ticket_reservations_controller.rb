class TicketReservationsController < ApplicationController
  layout :get_layout
  skip_before_filter :authenticate_user!, only: [:new, :show, :create, :destroy]
  before_filter :get_reservation, :get_group, only: [:show, :edit, :update, :destroy, :details]

  def index
    @shows = @group.events.shows
  end

  def show
  end

  def details
  end

  def new
    @reservation = TicketReservation.new
    @shows = Show.active.public.tickets_available
  end
  
  def create
    @shows = Show.active.public.tickets_available

    @reservation = TicketReservation.new(params[:ticket_reservation])
    # Find or Create Contact
    @contact = Contact.where(protocol: 'email', address: @reservation.email).first

    unless @contact
      @contact = Contact.create(protocol: 'email', address: @reservation.email, temporary_name: @reservation.name)
    end

    if !@event = @reservation.event
      return render action: 'new', error: 'No Performance Specified!'
    end

    if @event.available_tickets < @reservation.amount
      return render action: 'new', error: 'Not Enough Seats Available!'
      # if !params[:waitlist]
      #   return render action: 'waitlist'
      # elsif params[:waitlist] == 'all'
      #   @reservation.waitlist_amount = @reservation.amount
      #   @reservation.amount = 0
      # else
      #   @reservation.waitlist_amount = @reservation.amount - @event.available_tickets
      #   @reservation.amount = @event.available_tickets
      # end
    end

    @reservation.owner = @contact

    respond_to do |format|
      if @reservation.save
        format.html { redirect_to @reservation, notice: "You have reserved your ticket(s)!" }
      else
        @show = Show.active.public.first
        format.html { render action: 'new' }
      end
    end
  end
  
  def edit
  end

  def update
    @reservation.update_attributes(params[:ticket_reservation])

    redirect_to group_ticket_reservations_path(@group)
  end

  def destroy
    @reservation.update_attribute(:cancelled, true)

    TicketMailer.cancel_notification(@reservation).deliver!

    flash[:notice] = "You have successfully canceled #{@reservation.confirmation_code}!"

    redirect_to ticket_reservations_path
  end

  protected

  def get_reservation
    @reservation = TicketReservation.find_by_confirmation_code(params[:id])
  end

  def get_group
    @group = @reservation.event.owner
  end

  def get_layout
    if ['new', 'create', 'show', 'cancel'].include? action_name
      'pages'
    else
      'group'
    end
  end
end
