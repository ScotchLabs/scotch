class TicketReservationsController < ApplicationController
  layout 'pages', if: :pages_layout?

  def index
  end

  def show
    @reservation = TicketReservation.find_by_confirmation_code(params[:id])
  end

  def new
    @reservation = TicketReservation.new
    @show = Show.active.public.first
  end
  
  def create
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
      if !params[:waitlist]
        return render action: 'waitlist'
      elsif params[:waitlist] == 'all'
        @reservation.waitlist_amount = @reservation.amount
        @reservation.amount = 0
      else
        @reservation.waitlist_amount = @reservation.amount - @event.available_tickets
        @reservation.amount = @event.available_tickets
      end
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
  end

  def destroy
  end

  protected
  
  def pages_layout?
    @group.nil?
  end
end
