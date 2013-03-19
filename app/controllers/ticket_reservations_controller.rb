class TicketReservationsController < ApplicationController
  layout 'pages', if: :pages_layout?

  def index
  end

  def show
  end

  def new
    @reservation = TicketReservation.new
  end
  
  def create
    @reservation = TicketReservation.new(params[:ticket_reservation])
    # Find or Create Contact
    # If all tickets available
    # Reserve Tickets
    # If not all tickets available
    # Wailist
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
