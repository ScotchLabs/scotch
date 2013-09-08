class TicketMailer < ActionMailer::Base
  default from: "tickets@snstheatre.org"

  def ticket_confirmation(ticket_reservation)
    @reservation = ticket_reservation
    @contact = @reservation.owner

    mail(
      to: @contact.email,
      subject: "[ScotchBox] Ticket Confirmation - #{@reservation.event.show_time}")
  end

  def cancel_notification(ticket_reservation)
    @reservation = ticket_reservation
    @contact = @reservation.owner

    mail(
      to: @contact.email,
      subject: "[ScotchBox] Ticket Cancellation - #{@reservation.event.show_time}")
  end
end
