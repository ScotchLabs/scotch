$(document).ready(function(){
  $('.message-button').click(function(e) {
    var modal = $('#new-message');

    if (modal.length < 1) {
      $('.container .content').append("<div id='new-message' class='modal fade'></div>");
      modal = $('#new-message');
    }

    // modal.html('');

    modal.modal({
      remote: '/messages/new?nolayout=1'
    });
  });
});
