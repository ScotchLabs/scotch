$(function(){
  // apply the placeholder shim for the rich and prosperous elements.
  $('.placeholder-shim').placeholder();
  
  // autocomplete stuff
  $('#user_identifier').autocomplete('/users.js');
  $('.user_identifier').autocomplete('/users.js');
  
  // hijack the Colorboxed feedback form
  //hijackSubmitFeedbackLink();
})

// nutrum.com/weblog/unobtrusive-ajax-with-jquery-and-rails
function hijackSubmitFeedbackLink() {
  $('#feedback_form').submit(function() {
    $(this).ajaxSubmit({
      target: '#',
      clearForm: true,
      success: feedbackSuccess,
      error: feedbackError
    })
    return false
  })
}
function feedbackSuccess() {
  console.log('feedback success!')
}
function feedbackError() {
  console.log('feedback error!')
}
