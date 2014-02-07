var launchMessageModal;

$(document).ready(function(){
  $('.message-button').click(function(e) {
    launchMessageModal();
  });

  launchMessageModal = function() {
    var modal = $('#new-message');

    if (modal.length < 1) {
      $('.container .content').append("<div id='new-message' class='modal fade'></div>");
      modal = $('#new-message');
    }

    modal.modal({
      remote: '/messages/new?nolayout=1'
    });

    if ($('.navbar-collapse').height() != 0) {
      $('.navbar-collapse').height("0");
    }
  };
});
