var launchMessageModal;

$(document).ready(function(){
  $('.message-button').click(function(e) {
    launchMessageModal();
  });

  launchMessageModal = function(callback) {
    var modal = $('#new-message');

    if (modal.length < 1) {
      $('.container .content').append("<div id='new-message' class='modal fade'></div>");
      modal = $('#new-message');
    }

    modal.modal({
      show: true
    }).load('/messages/new?nolayout=1', function() {
      if (callback) {
        callback();
      }
    });

    if ($('.navbar-collapse').height() != 0) {
      $('.navbar-collapse').height("0");
    }
  };
});
