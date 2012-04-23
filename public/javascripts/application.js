$(function(){
  // apply the placeholder shim for the rich and prosperous elements.
  $('.placeholder-shim').placeholder();
  $('#user_identifier').autocomplete({source: "/users.json"});
  $('.user_identifier').autocomplete({source: "/users.json"});
});
