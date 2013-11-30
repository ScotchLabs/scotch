# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$('#ticket_reservation_amount').keyup ->
  update_amount()

$('#ticket_reservation_with_id').click ->
  update_amount()

update_amount = () ->
  amount_field = $('#ticket_reservation_amount')
  amount = amount_field.val();
  price_with = amount_field.attr("data-with")
  price_without = amount_field.attr("data-without")
  if amount == "" || isNaN(amount)
    amount = 0
  else
    amount = parseInt(amount, 10)
    cmu_id = $('#ticket_reservation_with_id:checked').length > 0;
    
    if cmu_id
      amount = amount * price_with
    else
      amount = amount * price_without

  $('.total').html("Total: $" + amount)
