/* README
 * This is basically how it goes:
 *   events are pulled first from the cache, then via ajax, group by group.
 *   events are displayed AS THEY ARE PARSED by the ajax call.
 *   events are then cached locally.
 *   when the user changes view of the calendar, events are refreshed.
 
 * precautions taken: events should not duplicate in the view, nor in the cache
 *   ajax calls do not duplicate per group
 */

var selectedGroups = [] // array of groups that are "selected" in the calside menu
var group_positions = {} // keeps track of the positions-holders of each group, and what filter each falls under
var dates_pulled = {} // keeps track of what dateranges we've ajaxed and cached.
var cachedEvents = {}
var calDebug = true
var obj // used for debug purposes
var ajax = {} // map of all open ajax calls
// When there's an error server-side ExceptionNotifier emails us so the user doesn't have to
var serverSideErrorMessage = " The developers have been notified. There's not much you can do now but wait for them to fix it."

$(document).ready(function() {
  // populate selectedGroups
  $.each($(".groupButton[selected=true]"), function(i, item) { selectedGroups.push(parseInt($(item).attr('id'))) })
  
  // set up the fullcalendar object
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    allDayDefault: false,
    // clicking on a day pops up a New Event form
    dayClick: function(date, allDay, jsEvent, view) {
      // http://arshaw.com/fullcalendar/docs/mouse/dayClick/
      newEvent(null, date, allDay)
    },
    // clicking on an event pops up an information view or Update Event form
    eventClick: function(event, jsEvent, view) {
      debugLog('showing event '+event.id)
      // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
      // build information view
      html = "<h1>"+event.title+"</h1>"+
        "<h2>"+event.group+((event.canEdit)? " <a href='javascript:void(0)' onclick='editEvent("+event.id+")'>Edit this</a>":"")+"</h2>"
      displayAttending = false
      if (!event.allDay) {
        html += "<b>Starts</b>: "+event.start+"<br>"+
          "<b>Ends</b>: "+event.end+"<br>"
      } else
        html += "All day "+event.start+"<br>"
      html+= "<b>Where</b>: "+event.location+"<br>"
      if (event.privacyType == "closed")
        html += "<b>This event is closed.</b><br>"
      else if (event.privacyType == "limited" && event.numAttendees == event.attendeeLimit)
        html += "<b>This event is limited and full.</b><br>"
      else {
        displayAttending = true
        if (event.privacyType == "open")
          html+= "<b>This event is open.</b> "  
        else if (event.privacyType == "limited")
          html+= "<b>This event is limited.</b> "
      }
      displayAttending = displayAttending || event.currentUserAttending!=-1
      if (displayAttending) {
        if (event.currentUserAttending != -1) {
          html+= "<span id='attending'>You are listed as attending. <a href='javascript:void(0)' onclick='attend(false,"+event.id+")'>I'm not attending.</a></span>"
          html+= "<span id='notAttending' class='hidden'>You are listed as not attending. <a href='javascript:void(0)' onclick='attend(true,"+event.id+")'>I'm attending.</a></span>"
        } else {
          html+= "<span id='attending' class='hidden'>You are listed as attending. <a href='javascript:void(0)' onclick='attend(false,"+event.id+")'>I'm not attending.</a></span>"
          html+= "<span id='notAttending'>You are listed as not attending. <a href='javascript:void(0)' onclick='attend(true,"+event.id+")'>I'm attending.</a></span>"
        }
        html+= "<span id='attendingDisabled' class='hidden' style='color:#ddd'>I'm attending.</span>"
        html+= "<span id='notAttendingDisabled' class='hidden' style='color:#ddd'>I'm not attending.</span>"
        html+= "<img id='attendLoading' class='hidden' src='/images/indicator.gif'>"
      }
      html+="<br>"
      html+= "<b>Attendees</b>: <span id='attendees'></span><img alt=\"Indicator\" id=\"attendeesLoading\" class='hidden' src=\"/images/indicator.gif\">"
      
      // display the information view
      $.colorbox({html:html,inline:false,width:"400px",height:"400px"})
      
      updateAttendees(event.id)
    },
    events: function(start, end, callback) {
      // http://arshaw.com/fullcalendar/docs/event_data/events_function/
      // this function is called whenever the calendar refreshes/refetches
      // we don't need milliseconds
      start=start.valueOf()/1000
      end=end.valueOf()/1000
      eventIds = [] // all the events that have been pulled this time around
      
      for (i in selectedGroups) {
        group_id = selectedGroups[i]
        
        // ajax if not cached
        if (!datesPulled(group_id,start,end)) {
          // make sure there isn't already an ajax call for this group's events
          if (ajax[group_id] == undefined) {
            $("#grouploading_"+group_id).show()
            url = '/groups/'+group_id+'/events.json'
            debugLog("pulling "+group_id+" events from "+url)
            ajax[group_id] = $.ajax({
              url: url,
              data: {"start":start,"end":end},
              success: function(data) {
                debugLog('success')
                // display and cache
                $.each(data.events, function(k) {
                  if ($.inArray(data.events[k].id, eventIds) == -1) {
                    $("#calendar").fullCalendar('renderEvent',data.events[k])
                    eventIds.push(data.events[k].id)
                  }
                  cachedEvents[data.events[k].id] = data.events[k]
                })
                // reset ajax flag
                dates_pulled[data.group_id].push([start,end])
                ajax[data.group_id] = undefined
                $("#grouploading_"+data.group_id).hide()
              },
              error: function(xhr, status, thrown) {
                group_id = parseInt(this.url.split('/')[2])
                $("#grouploading_"+group_id).hide()
                debugLog('error. status: '+status+', thrown: '+thrown)
                errorLog("There was a problem fetching event data."+serverSideErrorMessage)
              }
            
            })
          }
        } else { // found in cache
          $("#grouploading_"+group_id).show()
          debugLog('pulling '+group_id+' events from cache')
          //FIXME traverse cache
          for (l in cachedEvents) {
            item = cachedEvents[l]
            if (item["group_id"] != group_id)
              continue
            // display if not already displayed. should be a redundant measure?
            if ($.inArray(item.id, eventIds) == -1) {
              debugLog('pushing event from cache')
              $("#calendar").fullCalendar('renderEvent',item)
              eventIds.push(item.id)
            }
          }
          $("#grouploading_"+group_id).hide()
        }
      }
    }
  })
  
  var dates = $("#start_time, #end_time").datepicker({
    timeFormat: 'h:mm',
    // ex: if May 4 is your start date, May 3 is disabled for end date selection
    onSelect: function( selectedDate ) {
  		var option = this.id == "start_time" ? "minDate" : "maxDate",
  			instance = $( this ).data( "datepicker" );
  			date = $.datepicker.parseDate(
  				instance.settings.dateFormat ||
  				$.datepicker._defaults.dateFormat,
  				selectedDate, instance.settings );
  		dates.not( this ).datepicker( "option", option, date );
    },
    showOn: "button",
    buttonImage: "/images/cal.png",
    buttonImageOnly: true
  })
  $("#stop_on_date").datepicker({
    showOn: "button",
    buttonImage: "/images/cal.png",
    buttonImageOnly: true
  })
  
  populateInvitees()
})

function toggle(group_id) { // called when the user clicks on a group name to de/select it
  debugLog('toggling '+group_id)
  classes = $("#"+group_id).attr('class').split(' ')
  needle=/event_color_([0-9]+)/
  color = -1
  $.each(classes, function(i) {
    hay = classes[i]
    m = needle.exec(hay)
    if (m != null)
      color = m[1]
  })
  if (color == -1) debugLog('color not specified')
  if ($('#'+group_id).attr('selected')=='true') {
    debugLog('selected -> deselected')
    $('#'+group_id).attr('selected','false')
    $("#"+group_id).removeClass('event_color_'+color)
    $("#"+group_id).addClass('event_color_'+color+'_')
    $("#"+group_id).css("color","#333")
    selectedGroups.splice(selectedGroups.indexOf(group_id),1)
  } else {
    debugLog('deselected -> selected')
    $('#'+group_id).attr('selected','true')
    $("#"+group_id).removeClass('event_color_'+color+'_')
    $("#"+group_id).addClass('event_color_'+color)
    $("#"+group_id).css("color","#fff")
    selectedGroups.push(group_id)
  }
  // FIXME: there's probably a better way to handle toggling than refetching ALL events
  // but it's sort of moot since all refetching does is ask the cache for more.
  $("#calendar").fullCalendar('refetchEvents')
}
function newEvent(group_id, date, allDay) { // blanks and displays the form
  // blank out the form
  // page 1, part 1
  $("#new_event").attr('action','/events.json')
  $("#event_title").attr('value','')
  $("#event_description").text('')
  $("#event_location").attr('value','')
  $("#event_group_id").removeAttr('disabled')
  if (group_id != null) {
    $("#event_group_id option").removeAttr('selected')
    $("#event_group_id option[value='"+group_id+"']").attr('selected','selected')
    populateInvitees()
  }
  // page 1, part 2
  updateEventTimes(allDay)
  if (date) {
    $("#start_time").datetimepicker('setDate', date)
    if (allDay)
      date.setDate(date.getDate())
    else
      date.setHours(date.getHours()+1)
    $("#end_time").datetimepicker('setDate', date)
  }
  // page 1, part 3
  $("#_repeat").removeAttr('checked')
  updateRepeat()
  // page 2, part 1
  $("#event_privacy_type_open").click()
  // page 2, part 2
  $("#position_names").html('')
  // display form
  $.colorbox({href:"#newEventForm"})
}
function editEvent(event_id) { // populates the form with event's values, displays form
  e = cachedEvents[event_id]
  // populate form
  // page 1, part 1
  $("#new_event").attr('action','/events/'+event_id+'.json')
  $("#event_title").attr('value',e.title.split('] ')[1])
  $("#event_description").text(e.description)
  $("#event_location").attr('value',e.location)
  $("#event_group_id option").removeAttr('selected')
  $("#event_group_id option[value='"+e.group_id+"']").attr('selected',true)
  $("#event_group_id").attr('disabled',true)
  // page 1, part 2
  updateEventTimes(e.allDay)
  $("#start_time").datetimepicker('setDate',e.start)
  $("#end_time").datetimepicker('setDate',e.end)
  // page 1, part 3
  $("#_repeat").removeAttr('checked')
  updateRepeat()
  // page 2, part 1
  $("#event_privacy_type_"+e.privacyType).click()
  if (e.privacyType=='limited')
    $("#event_attendee_limit").attr('value',e.attendeeLimit)
  // page 2, part 2
  populateInvitees()
  //TODO when Attending/Attendees is implemented
  // display form
  $.colorbox({href:"#newEventForm"})
}
function updateEventTimes(allDay) { // primes the allDay field of the New Event form
  if (allDay == null)
    allDay = $("#event_all_day").attr('checked')
  if (allDay) {
    $("#event_all_day").attr('checked',true)
    $("#event_start_time_4i").attr('disabled',true)
    $("#event_start_time_5i").attr('disabled',true)
    $("#event_end_time_4i").attr('disabled',true)
    $("#event_end_time_5i").attr('disabled',true)
    $("#event_times .at").css('color','#ddd')
  } else {
    $("#event_all_day").removeAttr('checked')
    $("#event_start_time_4i").removeAttr('disabled')
    $("#event_start_time_5i").removeAttr('disabled')
    $("#event_end_time_4i").removeAttr('disabled')
    $("#event_end_time_5i").removeAttr('disabled')
    $("#event_times .at").css('color',"#333")
  }
}
function updateRepeat() { // primes the repeat fields of the New Event form
  repeats = $("#_repeat").attr('checked')
  if (repeats) {
    $("#_repeat_frequency").removeAttr('disabled')
    $("#_repeat_period").removeAttr('disabled')
    $("#stop_condition_type_occurrences").removeAttr('disabled')
    $("#stop_condition_type_date").removeAttr('disabled')
  }
  repeatStopOn = $("[name='stop_condition_type']:checked").val()
  if (repeatStopOn == "occurrences")
    $("#_stop_after_occurrences").removeAttr('disabled')
  else if (repeatStopOn == "date") {
    $("#stop_on_date").removeAttr('disabled')
    $("#_stop_on_time_1i").removeAttr('disabled')
    $("#_stop_on_time_2i").removeAttr('disabled')
    $("#_stop_on_time_3i").removeAttr('disabled')
    $("#_stop_on_time_4i").removeAttr('disabled')
    $("#_stop_on_time_5i").removeAttr('disabled')
    $("#repeat .at").css('color','#333')
  }
  if (repeatStopOn != "occurrences")
    $("#_stop_after_occurrences").attr('disabled',true)
  if (repeatStopOn != "date") {
    $("#stop_on_date").attr('disabled',true)
    $("#_stop_on_time_1i").attr('disabled',true)
    $("#_stop_on_time_2i").attr('disabled',true)
    $("#_stop_on_time_3i").attr('disabled',true)
    $("#_stop_on_time_4i").attr('disabled',true)
    $("#_stop_on_time_5i").attr('disabled',true)
    $("#repeat .at").css('color','#ddd')
  }
  if (!repeats) {
    $("#_repeat_frequency").attr('disabled',true)
    $("#_repeat_period").attr('disabled',true)
    $("#stop_condition_type_occurrences").attr('disabled',true)
    $("#stop_condition_type_date").attr('disabled',true)
    $("#_stop_after_occurrences").attr('disabled',true)
    $("#stop_on_date").attr('disabled',true)
    $("#repeat .at").css('color','#ddd')
    $("#_stop_on_time_1i").attr('disabled',true)
    $("#_stop_on_time_2i").attr('disabled',true)
    $("#_stop_on_time_3i").attr('disabled',true)
    $("#_stop_on_time_4i").attr('disabled',true)
    $("#_stop_on_time_5i").attr('disabled',true)
  }
}
function updateTime(sel) {
  // the time fields of the New Event form cannot be captured directly by the controller.
  // They must first be reparsed locally.
  arr = $("#"+sel).val().split('/')
  for (i in arr)
    if (arr[i] == undefined)
      arr[i] = ""
  if (sel != "stop_on_date")
    sel = "event_"+sel
  else
    sel = "_stop_on_time"
  $("#"+sel+"_1i").val(arr[2])
  $("#"+sel+"_2i").val(arr[0])
  $("#"+sel+"_3i").val(arr[1])
}
function submit_event_form() { // woo user-generated-content submission!
  // make sure the submitted times are reparsed such that they can be captured
  updateTime('start_time')
  updateTime('end_time')
  updateTime('stop_on_date')
  // make sure we don't submit all of the position lists, just the "Invitees" one
  $("#position_names option").attr("selected",true)
  // prime client-side validation
  $("#newFormError").hide()
  $("#new_event [type='submit']").attr('disabled',true)
  //TODO show loading
  $.ajax({
    url: $("#new_event").attr('action'),
    type: "POST",
    data: $("#new_event").serialize(),
    success: function(data, status, xhr) {
      if (data.events == undefined) {
        // INVALID INPUT
        $("#newFormError").show()
        $("#pageContainer").animate({"left":"0px"}, "fast")
        for (i in data) {
          $("#event_"+i).css('border-color','#f90')
        }
      } else {
        // VALID INPUT
        for (i in data.events) {
          cachedEvents[data.events[i].id] = data.events[i]
          $("#calendar").fullCalendar('renderEvent',data.events[i])
        }
        $.colorbox.close()
      }
    },
    error: function(xhr, status, thrown) {
      debugLog('error submitting new event form. status '+status+', thrown '+thrown)
      errorLog('There was a problem submitting the form.'+serverSideErrorMessage)
    },
    complete: function(xhr, status) {
      $("#new_event [type='submit']").removeAttr('disabled')
      //TODO hide loading
    }
  })
  return false // so that the form is not submitted normally
}
function attend(isAttending, event_id) { // ex: when you click "I'm attending"
  $("#attendLoading").show()
  url = ""
  if (isAttending) {
    $("#notAttending").hide()
    $("#attendingDisabled").show()
    url = "/events/"+event_id+"/event_attendees.json"
    
    $.ajax({
      type:"POST",
      data: {
        utf8:$("#new_event [name='utf8']").attr('value'),
        authenticity_token:$("#new_event [name='authenticity_token']").attr('value')
      },
      url:url,
      success:function(data){
        if (data.event_attendee == undefined) {
          $("#attendingDisabled").hide()
          $("#notAttending").show()
          html = "Input invalid."
          if (data.event)
            html += " Event "+data.event+"."
          if (data.user)
            html += " User "+data.user+"."
          obj = data
          errorLog(html)
        } else {
          ea = data.event_attendee.event_attendee
          cachedEvents[event_id].currentUserAttending=ea.id
          $("#attendingDisabled").hide()
          $("#attending").show()
        }
      },
      error:function(){
        $("#attendingDisabled").hide()
        $("#notAttending").show()
        debugLog('error attending '+event_id)
        errorLog('There was a problem submitting the data.'+serverSideErrorMessage)
      },
      complete:function(){
        $("#attendLoading").hide()
      }
    })
  }
  else {
    $("#attending").hide()
    $("#notAttendingDisabled").show()
    url = "/event_attendees/"+cachedEvents[event_id].currentUserAttending+".json"
    $.ajax({
      url:url,
      data: {
        utf8:$("#new_event [name='utf8']").attr('value'),
        authenticity_token:$("#new_event [name='authenticity_token']").attr('value')
      },
      type:"DELETE",
      complete:function(){
        cachedEvents[event_id].currentUserAttending=-1
        $("#notAttendingDisabled").hide()
        $("#notAttending").show()
        $("#attendLoading").hide()
      }
    })
  }
  updateAttendees(event_id)
}
function updateAttendees(event_id) {
  debugLog('updating attendees for '+event_id)
  
  debugLog('fetching attendees')
  $("#attendeesLoading").show()
  $.ajax({
    url: "/events/"+event_id+"/event_attendees.json",
    success: function(data){
      debugLog('updating listing')
      $("#attendees").html(attendees_to_str(event_id,data.attendees))
    },
    error: function(){
      errorLog("There was an error submitting the data."+serverSideErrorMessage)
      debugLog('update attendees errored')
    },
    complete: function(){
      $("#attendeesLoading").hide()
    }
  })
  
  
}
function attendees_to_str(event_id, as) {
  if (as == undefined || as.length == 0) return "none listed."
  str = ""
  str=as[as.length-1]
  debugLog("str stage 1: "+str)
  if (as.length > 1)
    str=as[as.length-2]+" and "+str
  debugLog("str stage 2: "+str)
  if (as.length > 2)
    str = as.slice(0,as.length-2).join(", ")+", "+str
  debugLog("str stage 3: "+str)
  debugLog(str)
  debugLog('attendees_to_str returning '+str)
  return str
}
function populateInvitees() { // populates the new/update event form with this group's position-holders
  $("#position_names").empty()
  debugLog('populating invitees')
  html = ""
  group_id = parseInt($("#event_group_id").val())
  $.each(group_positions[group_id], function(i,e) {
    name = e.name
    html += "<option value=\""+name+"\">"+name+"</option>"
  })
  $("#filter_select").html(html)
}
function filterInvitees() { // fires when a filter is clicked in the new/update event invite form
  if ($("#filter_select :selected")[0]!=undefined) {
    key=$("#filter_select :selected")[0].value
    html=""
    $.each(group_positions[group_id], function(i,e) {
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
  $("#position_names").append($("#position_select :selected").clone())
  // move searched names from the text input
  v=$("#user_identifier").attr('value')
  if (v!="") {
    // pull andrew id
    a=v.match(/([a-z]+)\@/)[1]
    html="<option value='"+a+"'>"+v+"</option>"
    $("#position_names").html($("#position_names").html()+html)
    $("#user_identifier").attr('value','')
  }
}
function updatePrivacy() { // ex: when a user clicks on "Open", "Closed" or "Limited"
  pt = $("[name='event[privacy_type]']:checked").val()
  if (pt == 'limited')
    $("#event_attendee_limit").removeAttr('disabled')
  else
    $("#event_attendee_limit").attr('disabled',true)
}
function datesPulled(g,s,e) {
  debugLog('asking if group '+g+' has dates pulled from '+s+' to '+e)
  a = false
  $.each(dates_pulled[g],function(i,el) {
    if (el[0]<=s&&el[1]>=e)
      a = true
  })
  debugLog(a)
  return a
}

function debugLog(s) {
  if (calDebug) console.log(s)
}
function errorLog(s) {
  $.colorbox({html:"<h1>Oops!</h1>"+s,inline:false,width:'400px'})
}
