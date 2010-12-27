/****************************
***  View All N Comments  ***
****************************/
function expand_comments(post_id) {
  jQuery('#view_error_'+post_id).hide()
  jQuery('#view_link_'+post_id).hide()
  jQuery('#loading_'+post_id).show()
  jQuery.ajax({type: 'get', url: '/feedposts/'+post_id+'.text', success: function(data, status, xhr){expand_success(post_id, data)}, error: function(xhr, status, thrown){expand_error(post_id, status, thrown)}})
}
function expand_success(post_id, data) {
  jQuery('#loading_'+post_id).hide()
  jQuery('#view_all_'+post_id).hide()
  html = ''
  recent_comments = [];
  jQuery('#recent_comments_'+post_id).children().each(function(){recent_comments.push($(this).attr('id').toString())})
  expanded_comments = jQuery('#expanded_comments_'+post_id)
  expanded_comments.hide()
  $(data).find("#recent_comments_"+post_id).children().each(function(){
    if (recent_comments.indexOf(this.id) == -1) {
      trim(this)
      html += "<div id='"+this.id+"' class='comment'>"+jQuery(this).html()+"</div>"
    }
  })
  expanded_comments.html(html)
  expanded_comments.show('fast')
}
function expand_error(post_id, status, thrown) {
  jQuery('#loading_'+post_id).hide()
  jQuery('#view_error_'+post_id).show()
}

/***************************
***  Comment Submission  ***
***************************/
function submit_comment(post_id) {
  jQuery("#error_submitting_"+post_id).hide()
  jQuery("#new_feedpost_form_"+post_id+" input[type='submit']").attr('disabled','true')
  jQuery("#submitting_"+post_id).show()
  var commit = $("#new_feedpost_form_"+post_id+" [type='submit']").attr('value')
  var utf8 = $("#new_feedpost_form_"+post_id+" [name='utf8']").attr('value')
  var auth = $("#new_feedpost_form_"+post_id+" [name='authenticity_token']").attr('value')
  var feedpost = {
    'parent_type':'Feedpost',
    'parent_id':post_id,
    'post_type':'comment',
    'headline':'comment',
    'body':jQuery('#new_feedpost_form_'+post_id+' textarea').attr('value')
    }
  jQuery.ajax({type: 'post', url: '/feedposts', data: {ajax: true, feedpost: feedpost, utf8: utf8, authenticity_token: auth, commit: commit}, success: function(data, status, xhr){submit_success(data, post_id)}, error: function(xhr, status, thrown){submit_error(post_id)}})
  
  return false
}
function submit_success(data, post_id) {
  jQuery("#new_feedpost_form_"+post_id+" input[type='submit']").removeAttr('disabled')
  jQuery("#submitting_"+post_id).hide()
  jQuery('#new_feedpost_form_'+post_id+' textarea').attr('value','')
  jQuery('#post_'+post_id+'_count').html(parseInt(jQuery('#post_'+post_id+'_count').html())+1)
  newComment = $(data).find("#recent_comments_"+post_id).children().last()
  trim(newComment)
  newCommentHtml = "<div id='"+newComment.attr('id')+"' class='comment'>"+newComment.html()+"</div>"
  $(newCommentHtml).hide().appendTo('#recent_comments_'+post_id).show('fast')
}
function submit_error(post_id) {
  jQuery("#new_feedpost_form_"+post_id+" input[type='submit']").removeAttr('disabled')
  jQuery("#submitting_"+post_id).hide()
  jQuery("#error_submitting_"+post_id).show()
}

/***************************
*** Comment Destruction  ***
***************************/
function delete_post(post_id) {
  sure = confirm("Are you sure you want to delete this post?")
  
  if (sure) {
    $("#post_"+post_id).hide('fast')
    var auth = $("#new_feedpost_form_"+post_id+" [name='authenticity_token']").attr('value')
    //TODO decrement View All N Comments
    $.ajax({type: 'DELETE', url: '/feedposts/'+post_id+'.xml', data: {authenticity_token: auth, id: post_id}})
  }
}

/**********************
*** Post Submission ***
**********************/
function submit_feedpost() {
  jQuery("#error_submitting").hide()
  jQuery("#postform input[type='submit']").attr('disabled','true')
  jQuery("#submitting").show()
  var commit = $("#postform [type='submit']").attr('value')
  var utf8 = $("#postform [name='utf8']").attr('value')
  var auth = $("#postform [name='authenticity_token']").attr('value')
  var feedpost = {
    'parent_type':jQuery('#postform #feedpost_parent_type').attr('value'),
    'parent_id':jQuery('#postform #feedpost_parent_id').attr('value'),
    'post_type':'wall',
    'headline':jQuery('#postform #feedpost_headline').attr('value'),
    'body':jQuery('#postform textarea').attr('value')
    }
  jQuery.ajax({type: 'post', url: '/feedposts', data: {ajax: true, feedpost: feedpost, utf8: utf8, authenticity_token: auth, commit: commit}, success: function(data, status, xhr){submit_feedpost_success(data)}, error: function(xhr, status, thrown){submit_feedpost_error()}})
  
  return false
}
function submit_feedpost_success(data) {
  jQuery("#postform input[type='submit']").removeAttr('disabled')
  jQuery("#submitting").hide()
  jQuery('#postform #feedpost_headline').attr('value','')
  jQuery('#postform textarea').attr('value','')
  newPostHtml = "<div id='"+$(data).attr('id')+"' class='feedpost'>"+$(data).html()+"</div>"
  $(newPostHtml).hide().prependTo('#feedposts').show('fast')
}
function submit_feedpost_error() {
  jQuery("#postform input[type='submit']").removeAttr('disabled')
  jQuery("#submitting").hide()
  jQuery("#error_submitting").show()
}

/***************
*** Trimming ***
***************/
$(document).ready(function(){
  $(".comment").each(function(i,s){trim(s)})
})
function trim(s) {
  if (s.id == undefined)
    return
  //console.log("trimming "+s.id)
  text = $(s).find('p').html()
  var less = ''
  var more = ''
  if (text.split("<br>").length > 5) {
    //console.log("case 1")
    less = text.split("<br>").slice(0,5).join("<br>")
    more = "<br>"+text.split("<br>").slice(5).join("<br>")
  } else if (text.split(". ").length > 5) {
    //console.log("case 2")
    less = text.split(". ").slice(0,5).join(". ")+". "
    more = text.split(". ").slice(5).join(". ")
  } else if (text.split(" ").length > 50) {
    //console.log("case 3")
    less = text.split(" ").slice(0,50).join(" ")
    more = " "+text.split(" ").slice(50).join(" ")
  } else {
    //console.log("else")
    less = text
  }
  morelink = "<a id='more_link_"+s.id+"' href='#none' onclick=\"$(this).hide(); $('#comment_more_"+s.id+"').show('fast')\">more...</a>"
  lesslink = "<a href='#none' onclick=\"$('#comment_more_"+s.id+"').hide('fast'); $('#more_link_"+s.id+"').show()\">...less</a>"
  if (more) {
    more = "<span id='comment_more_"+s.id+"' class='hidden'>"+more+"<br>"+lesslink+"</span>"
    text = less+more+"<br>"+morelink
  }
  $(s).find('p').html(text)
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
  //console.log("blur called on "+post_id)
  value = $('#'+post_id+" textarea").attr('value')
  placeholder = $('#'+post_id+" textarea").attr('placeholder')
  //console.log("value: "+value)
  //console.log("placeholder: "+placeholder)
  if (value == '' ||value == placeholder) {
    //console.log("do it")
    $('#'+post_id+" textarea").attr('rows','2')
    $('#'+post_id+" [type='submit']").hide()
  }
}
