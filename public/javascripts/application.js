$(function(){
  $('.placeholder-shim').placeholder();
  
  numnav = $('#nav ul li').size();
  $('#nav ul li').css('width',900/numnav-21);
  $('#nav ul li a').css('width',900/numnav-21);
})

$(document).ready(function(){
  $('#user_identifier').autocomplete('/users.js');
  $('.user_identifier').autocomplete('/users.js');
})
