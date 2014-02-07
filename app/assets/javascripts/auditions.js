$(document).ready(function() {
  $('.audition-recipient-form').submit(function(e) {
    e.preventDefault();

    var recipients = $('.audition-recipient:checked').map(function() {
      return this.value;
    }).get();

    launchMessageModal();

    $('#new-message').on('shown.bs.modal', function() {
      var recipientsField = $('#new-message .recipients_field')[0];
      recipientsField.selectize.clear();

      recipients.forEach(function(recipient) {
        console.log(recipient);
        var fields = recipient.split(':');
        console.log(fields);
        recipientsField.selectize.addOption({name: fields[1], value: fields[0] + ':User'});
        recipientsField.selectize.addItem(fields[0] + ':User');
      });
    });
  });
});
