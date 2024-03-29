/****************************
***  View All N Comments  ***
****************************/
function expand_comments(post_id) {
  // reset errors, set loading
  $('#view_error_'+post_id).hide()
  $('#view_link_'+post_id).hide()
  $('#loading_'+post_id).show()
  // request the page
  $.ajax({
    type: 'get',
    url: '/feedposts/'+post_id, data: {ajax:true},
    success: function(data, status, xhr){expand_success(post_id, data)},
    error: function(xhr, status, thrown){expand_error(post_id, status, thrown)}
  })
}
function expand_success(post_id, data) {
  // reset loading
  $('#loading_'+post_id).hide()
  $('#view_all_'+post_id).hide()
  // process data
  html = ''
  recent_comments = [];
  $('#recent_comments_'+post_id).children().each(function(){recent_comments.push($(this).attr('id').toString())})
  expanded_comments = $('#expanded_comments_'+post_id)
  expanded_comments.hide()
  // trim comment and add to output
  $(data).find("#recent_comments_"+post_id).children().each(function(){
    if (recent_comments.indexOf(this.id) == -1) {
      html += "<div id='"+this.id+"' class='comment'>"+$(this).html()+"</div>"
    }
  })
  expanded_comments.html(html)
  expanded_comments.show('fast')
}
function expand_error(post_id, status, thrown) {
  // reset loading, set error
  $('#loading_'+post_id).hide()
  $('#view_error_'+post_id).show()
}

/***************************
***  Comment Submission  ***
***************************/
function submit_comment(post_id) {
  // reset errors
  $("#error_submitting_"+post_id).hide()
  $("#post_invalid_"+post_id).hide()
  // validate data
  if (!$('#new_feedpost_form_'+post_id+' textarea').attr('value')) {
    // set error
    $("#post_invalid_"+post_id).show()
  } else {
    // lock form, set loading
    $("#new_feedpost_form_"+post_id+" input[type='submit']").attr('disabled','true')
    $("#submitting_"+post_id).show()
    // gather data
    var commit = $("#new_feedpost_form_"+post_id+" [type='submit']").attr('value')
    var utf8 = $("#new_feedpost_form_"+post_id+" [name='utf8']").attr('value')
    var auth = $("[name='csrf-token']").attr('content')
    var feedpost = {
      'parent_type':'Feedpost',
      'parent_id':post_id,
      'post_type':'comment',
      'headline':'comment',
      'body':$('#new_feedpost_form_'+post_id+' textarea').attr('value')
      }
    // send request
    $.ajax({
      type: 'post',
      url: '/feedposts',
      data: {
        ajax: true,
        feedpost: feedpost,
        utf8: utf8,
        authenticity_token: auth,
        commit: commit
      },
      success: function(data, status, xhr){submit_success(data, post_id)},
      error: function(xhr, status, thrown){submit_error(post_id)}
    })
  }
  return false
}
function submit_success(data, post_id) {
  // unlock form, reset loading
  $("#new_feedpost_form_"+post_id+" input[type='submit']").removeAttr('disabled')
  $("#submitting_"+post_id).hide()
  // clear form
  $('#new_feedpost_form_'+post_id+' textarea').attr('value','')
  // display new view
  $('#post_'+post_id+'_count').html(parseInt($('#post_'+post_id+'_count').html())+1)
  newComment = $(data).find("#recent_comments_"+post_id).children().last()
  newCommentHtml = "<div id='"+newComment.attr('id')+"' class='comment'>"+newComment.html()+"</div>"
  $(newCommentHtml).hide().appendTo('#recent_comments_'+post_id).show('fast')
}
function submit_error(post_id) {
  // unlock form, hide loading, set error
  $("#new_feedpost_form_"+post_id+" input[type='submit']").removeAttr('disabled')
  $("#submitting_"+post_id).hide()
  $("#error_submitting_"+post_id).show()
}

/***************************
*** Comment Destruction  ***
***************************/
function delete_post(post_id) {
  sure = confirm("Are you sure you want to delete this post?")
  
  if (sure) {
    $("#post_"+post_id).hide('fast')
    var auth = $("[name='csrf-token']").attr('content')
    //TODO decrement View All N Comments
    $.ajax({
      type: 'DELETE',
      url: '/feedposts/'+post_id+'.xml',
      data: {
        authenticity_token: auth
      }
    })
  }
}

/**********************
*** Post Submission ***
**********************/
function submit_feedpost() {
  // reset errors
  $("#error_submitting").hide()
  $("#post_invalid").hide()
  // validate data
  if (!$('#postform textarea').attr('value')) {
    // set error
    $("#post_invalid").show()
  } else {
    // lock form, set loading
    $("#postform input[type='submit']").attr('disabled','true')
    $("#submitting").show()
    // gather data
    var commit = $("#postform [type='submit']").attr('value')
    var utf8 = $("#postform [name='utf8']").attr('value')
    var auth = $("[name='csrf-token']").attr('content')
    var feedpost = {
      'parent_type':$('#postform #feedpost_parent_type').attr('value'),
      'parent_id':$('#postform #feedpost_parent_id').attr('value'),
      'post_type':'wall',
      'headline':$('#postform #feedpost_headline').attr('value'),
      'body':$('#postform textarea').attr('value'),
      'privacy':$('#postform #feedpost_privacy').attr('value'),
      'document_id':$('#postform #document_id').attr('value')
    }
    var email = ""
    if ($("#email") != undefined && $("#email").attr("checked"))
      email = "email"
    var email_names = []
    if ($("#email_names")[0] != undefined)
      for (i=0; i<$("#email_names")[0].options.length; i++)
        email_names.push($("#email_names")[0].options[i].value)
    // request page
    $.ajax({
      type: 'post', 
      url: '/feedposts', 
      data: {
        ajax: true, 
        feedpost: feedpost, 
        utf8: utf8, 
        authenticity_token: auth, 
        commit: commit, 
        email: email, 
        email_names: email_names
      }, 
      success: function(data, status, xhr){submit_feedpost_success(data)}, 
      error: function(xhr, status, thrown){submit_feedpost_error()}
    })
  }
  return false
}
function submit_feedpost_success(data) {
  // unlock form, reset loading, clear form
  $("#postform input[type='submit']").removeAttr('disabled')
  $("#submitting").hide()
  $('#postform #feedpost_headline').attr('value','')
  $('#postform textarea').attr('value','')
  // display new view
  newPostHtml = "<div id='"+$(data).attr('id')+"' class='feedpost'>"+$(data).html()+"</div>"
  $(newPostHtml).hide().prependTo('#feedposts').show('fast')
}
function submit_feedpost_error() {
  // unlock form, reset loading, set error
  $("#postform input[type='submit']").removeAttr('disabled')
  $("#submitting").hide()
  $("#error_submitting").show()
}
function filterInvitees() { // fires when a filter is clicked in the new/update event invite form
  if ($("#filter_select :selected")[0]!=undefined) {
    key=$("#filter_select :selected")[0].value
    html=""
    $.each(positions, function(i,e) {
      if (e.name==key) {
        $.each(e.positions, function(j,p) {
          html += "<option value=\""+p.andrewid+"\">"+p.user_name+" ("+p.position+")</option>"
        })
      }
    })
    $("#position_select").html(html)
    $("#position_select option").attr("selected",true)
  }
}
function addInvitees() { // fires when the -> arrow is clicked in the invite people form
  // move selected names from the middle select box
  $("#email_names").append($("#position_select :selected").clone())
  // move searched names from the text input
  v=$("#user_identifier").attr('value')
  if (v!="") {
    // pull andrew id
    a=v.match(/([a-z]+)\@/)[1]
    html="<option value='"+a+"'>"+v+"</option>"
    $("#email_names").html($("#email_names").html()+html)
    $("#user_identifier").attr('value','')
  }
}

/*************************
*** Comment Focus/Blur ***
*************************/
function focus_comment(post_id) {
  $("#new_feedpost_form_"+post_id+" textarea").attr('rows','3')
  $("#new_feedpost_form_"+post_id+" [type='submit']").show()
}
$(document).ready(function(){
  $('.new_feedpost_form').focusout(function(){blur_comment(this.id)})
})
function blur_comment(post_id) {
  value = $('#'+post_id+" textarea").attr('value')
  placeholder = $('#'+post_id+" textarea").attr('placeholder')
  if (value == '' ||value == placeholder) {
    $('#'+post_id+" textarea").attr('rows','2')
    $('#'+post_id+" [type='submit']").hide()
  }
}
