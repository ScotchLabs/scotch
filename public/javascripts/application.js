$(function(){
  $('.placeholder-shim').placeholder();
})

$(document).ready(function(){
  $('#user_identifier').autocomplete('/users.js');
  $('.user_identifier').autocomplete('/users.js');
})
