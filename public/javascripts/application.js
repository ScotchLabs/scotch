$(function(){
  // apply the placeholder shim for the rich and prosperous elements.
  $('.placeholder-shim').placeholder();
  
  // dynamically size the navitems: because some people have more than others
  //numnav = $('#nav > ul> li').size();
  //$('#nav > ul > li').css('width',900/numnav-21);
  //$('#nav > ul > li a').css('width',900/numnav-21);
  
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
