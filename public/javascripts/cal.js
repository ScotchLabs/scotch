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
var debugLevel = 3 // hide some debug messages
var obj // used for debug purposes
var ajax = {} // map of all open ajax calls, by data (only for group/event pulls)
var registrar = {} // map of all open loading images. controlled by register()
var revertFunctions = {} // map of all the revert functions
var watcher = {} // map of all the ajax watchers. controlled by watch()
// When there's an error server-side ExceptionNotifier emails us so the user doesn't have to
var serverSideErrorMessage = " The developers have been notified. There's not much you can do now but wait for them to fix it."

$(document).ready(function() {
  // populate selectedGroups
  $.each($(".groupButton[selected=true]"), function(i, item) { selectedGroups.push(parseInt($(item).attr('id'))) })
  
  // set up the fullcalendar object
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    allDayDefault: false,
    editable: true, // events can be dragged and resized
    dayClick: function(date, allDay, jsEvent, view) { // clicking on a day pops up a New Event form
      // http://arshaw.com/fullcalendar/docs/mouse/dayClick/
      newEvent(null, date, allDay)
    },
    eventClick: function(event, jsEvent, view) { // clicking on an event pops up an information view
      showEvent(event);
    },
    events: function(start, end, callback) { // this function is called whenever the calendar refreshes/refetches
      // http://arshaw.com/fullcalendar/docs/event_data/events_function/
      // we don't need milliseconds
      start=start.valueOf()/1000
      end=end.valueOf()/1000
      eventIds = [] // all the events that have been pulled this time around
      ajaxThese = []
      for (i in selectedGroups) {
        group_id = selectedGroups[i]
        
        // ajax if not cached
        if (!datesPulled(group_id,start,end)) {
          // make sure this group is not in any open ajax calls for this start/end
          if (ajax[group_id] == undefined) {
            ajaxThese.push(group_id)
          }
        } else { // found in cache
          register("#grouploading_"+group_id,'caches'+start+'e'+end+'g'+group_id,'show')
          debugLog('pulling '+group_id+' events from cache',0)
          //FIXME traverse cache
          for (l in cachedEvents) {
            item = cachedEvents[l]
            if (item["group_id"] != group_id)
              continue
            // display if not already displayed. should be a redundant measure?
            if ($.inArray(item.id, eventIds) == -1) {
              debugLog('pushing event from cache',0)
              $("#calendar").fullCalendar('renderEvent',item)
              eventIds.push(item.id)
            }
          }
          register("#grouploading_"+group_id,'caches'+start+'e'+end+'g'+group_id,'hide')
        }
      }
      url = '/events.json'
      ref = "s"+start+"e"+end+"g"+ajaxThese.join('|')
      for (i in ajaxThese)
        register("#grouploading_"+ajaxThese[i],ref,'show')
      ajax[ref] = $.ajax({
        url: url,
        data: {"start":start,"end":end,"group_ids":ajaxThese,"ref":ref},
        success: function(data) {
          // display and cache
          $.each(data.events, function(k,ev) {
            if ($.inArray(ev.id, eventIds) == -1) {
              $("#calendar").fullCalendar('renderEvent',ev)
              eventIds.push(ev.id)
            }
            cachedEvents[ev.id] = ev
          })
          // reset ajax flag
          ajax[data.ref] = undefined
          for (i in ajaxThese) {
            group_id = ajaxThese[i]
            dates_pulled[group_id].push([start,end])
            register("#grouploading_"+group_id,data.ref,'hide')
          }
          watchReg(data.ref,'unwatch','error')
        },
        error: function(xhr, status, thrown) {
          debugLog('error. status: '+status+', thrown: '+thrown)
          errorLog("There was a problem fetching event data."+serverSideErrorMessage)
        }
      })
      ajax[ref].ref = ref
      callback = ""
      for (i in ajaxThese)
        callback += "register('#grouploading_"+ajaxThese[i]+"','"+ref+"','reset');"
      watchReg(ref,'watch','error',callback)
    },
    eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) { // triggered when event is dropped and is moved to a DIFFERENT day/time
      // http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
      updateEvent(event.id,revertFunc)
    },
    eventResize: function(event, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view) { // triggered when resizing stops and event has changed duration
      // http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
      updateEvent(event.id,revertFunc)
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

// these functions manipulate the new event form
function newEvent(group_id, date, allDay) { // blanks and displays the form
  // blank out the form
  $("#newFormError").hide()
  //TODO remove css border-color
  // page 1, part 1
  $("#new_event").attr('action','/events.json')
  $("#new_event").attr('method','post')
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
  $("#propagate").hide()
  $("#repeat").show()
  $("#_repeat").removeAttr('checked')
  updateRepeat()
  $("#event_submit").attr('value','Create Event')
  $("#event_submit_2").attr('value','Create Event')
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
  $("#newFormError").hide()
  //TODO remove css border-color
  // page 1, part 1
  $("#new_event").attr('action','/events/'+event_id+'.json')
  $("#new_event").attr('method','PUT')
  $("#event_title").attr('value',e.title.split('] ')[1])
  $("#event_description").text(e.description)
  $("#event_location").attr('value',e.location)
  $("#event_group_id option").removeAttr('selected')
  $("#event_group_id option[value='"+e.group_id+"']").attr('selected',true)
  $("#event_group_id").attr('disabled',true)
  // page 1, part 2
  updateEventTimes(e.allDay)
  $("#start_time").datetimepicker('setDate',e.start)
  if (e.end != null)
    $("#end_time").datetimepicker('setDate',e.end)
  else // fc seems to null end_time when it's equal to start_time
    $("#end_time").datetimepicker('setDate',e.start)
  // page 1, part 3
  $("#_repeat").removeAttr('checked')
  updateRepeat()
  $("#repeat").hide()
  $("#propagate").show()
  $("#event_submit").attr('value','Update Event')
  $("#event_submit_2").attr('value','Update Event')
  // page 2, part 1
  $("#event_privacy_type_"+e.privacyType).click()
  if (e.privacyType=='limited')
    $("#event_attendee_limit").attr('value',e.attendeeLimit)
  // page 2, part 2
  populateInvitees()
  //TODO update invitees with attendees?
  // display form
  $.colorbox({href:"#newEventForm"})
}
function showEvent(event) {
  debugLog('showing event '+event.id,0)
  // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
  // build information view
  html = "<h1>"+event.title+"</h1>"+
    ((event.editable)? "<span class='delete_link fright hidden'><a href='javascript:void(0)' onclick='deleteEvent("+event.id+")'><img alt='Delete_icon' height='8' width='8' src='/images/delete_icon.png'></a></span>":"")+
    "<h2>"+event.group+((event.editable)? " <a href='javascript:void(0)' onclick='editEvent("+event.id+")'>Edit this</a>":"")+"</h2>"
  displayAttending = false
  if (!event.allDay) {
    html += "<b>Starts</b>: "+event.formattedStart+"<br>"+
      "<b>Ends</b>: "+event.formattedEnd+"<br>"
  } else
    html += "All day "+event.formattedStart+"<br>"
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
      html+= "<span id='attending"+event.id+"'>You are listed as attending. <a href='javascript:void(0)' onclick='attend(false,"+event.id+")'>I'm not attending.</a></span>"
      html+= "<span id='notAttending"+event.id+"' class='hidden'>You are listed as not attending. <a href='javascript:void(0)' onclick='attend(true,"+event.id+")'>I'm attending.</a></span>"
    } else {
      html+= "<span id='attending"+event.id+"' class='hidden'>You are listed as attending. <a href='javascript:void(0)' onclick='attend(false,"+event.id+")'>I'm not attending.</a></span>"
      html+= "<span id='notAttending"+event.id+"'>You are listed as not attending. <a href='javascript:void(0)' onclick='attend(true,"+event.id+")'>I'm attending.</a></span>"
    }
    html+= "<span id='attendingDisabled"+event.id+"' class='hidden' style='color:#ddd'>I'm attending.</span>"
    html+= "<span id='notAttendingDisabled"+event.id+"' class='hidden' style='color:#ddd'>I'm not attending.</span>"
    html+= "<img id='attendLoading"+event.id+"' class='hidden' src='/images/indicator.gif'>"
  }
  html+="<br>"
  html+= "<b>Attendees</b>: <span id='attendees'></span><img alt=\"Indicator\" id=\"attendeesLoading"+event.id+"\" class='hidden' src=\"/images/indicator.gif\">"
  
  // display the information view
  $.colorbox({html:html,inline:false,width:"400px",height:"400px"})
  
  updateAttendees(event.id)
}
function updateEventTimes(allDay) { // primes the allDay field of the New Event form
  if (allDay == null)
    allDay = $("#event_all_day").attr('checked')
  if (allDay) {
    $("#event_all_day").attr('checked',true)
    $("#start_time_inputs").hide()
    $("#end_time_inputs").hide()
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
    $("#start_time_inputs").show()
    $("#end_time_inputs").show()
    $("#event_times .at").css('color',"#333")
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
function updatePrivacy() { // ex: when a user clicks on "Open", "Closed" or "Limited"
  pt = $("[name='event[privacy_type]']:checked").val()
  if (pt == 'limited')
    $("#event_attendee_limit").removeAttr('disabled')
  else
    $("#event_attendee_limit").attr('disabled',true)
}

// these functions are more like events than functions
function updateEvent(event_id,revertFunc) { // fires when events are dragged or resized
  e = cachedEvents[event_id]
  ref = "update"+event_id+Date.now()
  register("#grouploading_"+e.group_id,ref,'show')
  debugLog('storing revert func with reference',0)
  revertFunctions[ref] = revertFunc
  data = {
    ref:ref,
    utf8:$("#new_event [name='utf8']").attr('value'),
    authenticity_token:$("#new_event [name='authenticity_token']").attr('value'),
    id: e.id,
    propagate: false,
    event:{"start_time(1i)":e.start.getFullYear(),
    "start_time(2i)":(e.start.getMonth()+1),
    "start_time(3i)":e.start.getDate(),
    "start_time(4i)":e.start.getHours(),
    "start_time(5i)":e.start.getMinutes()}
  }
  if (e.end != null) {
    data["event"]["end_time(1i)"]=e.end.getFullYear(),
    data["event"]["end_time(2i)"]=e.end.getMonth()+1,
    data["event"]["end_time(3i)"]=e.end.getDate(),
    data["event"]["end_time(4i)"]=e.end.getHours(),
    data["event"]["end_time(5i)"]=e.end.getMinutes()
  } else { // fc seems to null the end time when it's equal to the start value
    data["event"]["end_time(1i)"]=e.start.getFullYear(),
    data["event"]["end_time(2i)"]=e.start.getMonth()+1,
    data["event"]["end_time(3i)"]=e.start.getDate(),
    data["event"]["end_time(4i)"]=e.start.getHours(),
    data["event"]["end_time(5i)"]=e.start.getMinutes()
  }
  a=$.ajax({
    type:'PUT',
    url:'/events/'+e.id+'.json',
    data:data,
    success: function(data) {
      if (data.errors != undefined) {
        html = "There was a problem with the data that was sent. <br>"
        for (key in data.errors)
          for (i in data.errors[key])
            html += key+" "+data.errors[key][i]+"<br>"
        errorLog(html)
        revertFunctions[data.ref]()
      }
      register("#grouploading_"+data.group_id,data.ref,'hide')
      watchReg(data.ref,'unwatch','error')
    },
    error: function(xhr, status, thrown) {
      debugLog('error. status: '+status+', thrown: '+thrown)
      errorLog("There was a problem sending the data."+serverSideErrorMessage)
    }
  })
  a.ref=ref
  watchReg(ref,'watch','error',"revertFunctions[\""+ref+"\"]();register('#grouploading_"+e.group_id+"','"+ref+"','hide')")
}
function deleteEvent(event_id) { // fires when user hits the button to delete an event
  sure = confirm("Are you sure you want to delete this event?")
  $.colorbox.close()
  ref = "delete"+event_id+Date.now()
  register('#groupLoading_'+event_id,ref,'show')
  if (sure) {
    delete cachedEvents[event_id]
    a=$.ajax({
      data:{ref:ref},
      type: 'DELETE',
      url: '/events/'+event_id+'.json',
      data: {authenticity_token:$("#new_event [name='authenticity_token']").attr('value')},
      complete: function(xhr) {
        data = $.parseJSON(xhr.response)
        register('#groupLoading_'+data.event_id,data.ref,'hide')
      }
    })
    a.ref=ref
  }
  $("#calendar").fullCalendar('refetchEvents')
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
  //TODO remove css border-color
  $("#new_event [type='submit']").attr('disabled',true)
  a=$.ajax({
    url: $("#new_event").attr('action'),
    type: $("#new_event").attr('method'),
    data: $("#new_event").serialize(),
    success: function(data, status, xhr) {
      if (data.events == undefined && data.event == undefined) {
        // INVALID INPUT
        $("#newFormError").show()
        $("#pageContainer").animate({"left":"0px"}, "fast")
        for (i in data.errors) {
          if (i != "start_time" && i != "end_time")
            i="event_"+i
          $("#"+i).css('border-color','#f90')
        }
        obj = data
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
    }
  })
  a.ref='submitEventForm'
  return false // so that the form is not submitted normally
}

// these functions relate to Attending
function attend(isAttending, event_id) { // ex: when you click "I'm attending"
  ref = 'attending'+Date.now()
  register("#attendLoading"+event_id,ref,'show')
  url = ""
  if (isAttending) {
    // since there will only be onle of these requests at a time we don't have to register these
    // this is good because some of them aren't hidden by default, which is the premise of register()
    $("#notAttending"+event_id).hide()
    $("#attendingDisabled"+event_id).show()
    url = "/events/"+event_id+"/event_attendees.json"
    
    a=$.ajax({
      type:"POST",
      data: {
        ref:ref,
        utf8:$("#new_event [name='utf8']").attr('value'),
        authenticity_token:$("#new_event [name='authenticity_token']").attr('value')
      },
      url:url,
      success:function(data){
        if (data.event_attendee == undefined) {
          // invalid
          $("#notAttending"+data.event_id).show()
          $("#attendingDisabled"+data.event_id).hide()
          // this should only happen if function was tampered with
          html = "There was a problem with the data that was sent. <br>"
          for (key in data.errors)
            for (i in data.errors[key])
              html += key+" "+data.errors[key][i]+"<br>"
          errorLog(html)
        } else {
          // valid
          ea = data.event_attendee.event_attendee
          cachedEvents[data.event_id].currentUserAttending=ea.id
          $("#attendingDisabled"+data.event_id).hide()
          $("#attending"+data.event_id).show()
        }
        register("#attendLoading"+data.event_id,data.ref,'hide')
        watchReg(data.ref,'unwatch','error')
      },
      error:function(){
        debugLog('error attending '+event_id)
        errorLog('There was a problem submitting the data.'+serverSideErrorMessage)
      }
    })
    a.ref=ref
    watchReg(ref,'watch','error',"$('#notAttending"+event_id+"').show();$('#attendingDisabled"+event_id+"').hide()")
  }
  else {
    $("#attending"+event_id).hide()
    $("#notAttendingDisabled"+event_id).show()
    url = "/event_attendees/"+cachedEvents[event_id].currentUserAttending+".json"
    a=$.ajax({
      url:url,
      data: {
        ref:ref,
        utf8:$("#new_event [name='utf8']").attr('value'),
        authenticity_token:$("#new_event [name='authenticity_token']").attr('value')
      },
      type:"DELETE",
      complete:function(data){
        data = $.parseJSON(data.response)
        cachedEvents[event_id].currentUserAttending=-1
        $("#notAttendingDisabled"+data.event_id).hide()
        $("#notAttending"+data.event_id).show()
        register('#attendLoading'+data.event_id,data.ref,'hide')
      }
    })
    a.ref=ref
  }
  updateAttendees(event_id)
}
function updateAttendees(event_id) {
  debugLog('updating attendees for '+event_id,0)
  ref = 'attendees'+event_id+Date.now()
  register("#attendeesLoading"+event_id,ref,'show')
  a=$.ajax({
    data:{ref:ref},
    url: "/events/"+event_id+"/event_attendees.json",
    success: function(data){
      debugLog('updating listing',1)
      $("#attendees").html(attendees_to_str(data.event_id,data.attendees))
      register("#attendeesLoading"+data.event_id,data.ref,'hide')
      watchReg(data.ref,'unwatch','error',null)
    },
    error: function(){
      errorLog("There was an error submitting the data."+serverSideErrorMessage)
      debugLog('update attendees errored')
      register('#attendeesLoading',null,'reset')
    }
  })
  a.ref=ref
  watchReg(ref,'watch','error',"register(\"#attendeesLoading"+event_id+"\",'"+ref+"','show')")
}
function attendees_to_str(event_id, as) {
  temp = []
  as = as.map(function(e){temp.push(e.name)})
  as = temp
  if (as == undefined || as.length == 0) return "none listed."
  str = ""
  str=as[as.length-1]
  debugLog("str stage 1: "+str,0)
  if (as.length > 1)
    str=as[as.length-2]+" and "+str
  debugLog("str stage 2: "+str,0)
  if (as.length > 2)
    str = as.slice(0,as.length-2).join(", ")+", "+str
  debugLog("str stage 3: "+str,0)
  debugLog(str,0)
  debugLog('attendees_to_str returning '+str,0)
  return str
}

// these functions relate to Invitees
function populateInvitees() { // populates the new/update event form with this group's position-holders
  $("#position_names").empty()
  debugLog('populating invitees',0)
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

// random helper functions
function toggle(group_id) { // called when the user clicks on a group name to de/select it
  debugLog('toggling '+group_id,0)
  classes = $("#"+group_id).attr('class').split(' ')
  needle=/event_color_([0-9]+)/
  color = -1
  $.each(classes, function(i) {
    hay = classes[i]
    m = needle.exec(hay)
    if (m != null)
      color = m[1]
  })
  if (color == -1) debugLog('color not specified',0)
  if ($('#'+group_id).attr('selected')=='true') {
    debugLog('selected -> deselected',0)
    $('#'+group_id).attr('selected','false')
    $("#"+group_id).removeClass('event_color_'+color)
    $("#"+group_id).addClass('event_color_'+color+'_')
    $("#"+group_id).css("color","#333")
    selectedGroups.splice(selectedGroups.indexOf(group_id),1)
  } else {
    debugLog('deselected -> selected',0)
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
function register(imageId,ajaxRef,command) { // for when loading images correspond to multiple ajax requests
  debugLog("registering image id '"+imageId+"' with ajax reference '"+ajaxRef+"' and command '"+command+"'",2)
  if (registrar[imageId] == undefined)
    registrar[imageId] = {}
  if (ajaxRef != null)
    registrar[imageId][ajaxRef] = command
  else if (ajaxRef == null && command == 'reset')
    for (ref in registrar[imageId])
      if (registrar[imageId][ref] == 'show')
        registrar[imageId][ref] = 'reset'
  showImg = false
  for (ref in registrar[imageId])
    if (registrar[imageId][ref] == 'show')
      showImg = true
  if (showImg) eval("$(\""+imageId+"\").show()")
  else eval("$(\""+imageId+"\").hide()")
}
$(document).ajaxComplete(function(e, xhr, settings){
  watchGo(xhr.ref,'complete')
})
$(document).ajaxError(function(e, xhr, settings, exception) {
  watchGo(xhr.ref,'error')
})
$(document).ajaxSuccess(function(e, xhr, settings) {
  watchGo(xhr.ref,'success')
})
function watchReg(ref,command,event,callback) { // for when ajax requests error and we still need to callback
  /* Usage:
  xhr: the xhr you want to watch. optional
    it must have a field ref that contains a unique id
  ref: the ref of the xhr you want to watch
  commands:
    watch   : use this to register a callback to fire when an event happens
    unwatch : use this with an event to remove the callback, or use with event=null to remove all commands
  events:
    complete : ajax request is done, whether it succeeded or errored
    error    : server doesn't return 200OK
    success  : server returns 200OK
  callback:
    not a real callback, but something to eval. because i don't have internet right now and can't look up how to do callbacks with arguments
  we don't watch start or stop ajax events because they don't have parameters to identify xhr
  we don't watch send ajax events because the xhr doesn't have a ref at that point
  registering a callback will overwrite the previous callback of that command
  */
  debugLog("registering watch for '"+ref+"' with command '"+command+"', event '"+event+"' and callback '"+callback+"'",3)
  if (ref == null || ref == undefined) {
    debugLog("can't watch without a ref",3)
    return
  }
  
  
  if (watcher[ref] == undefined)
    watcher[ref] = {}
  if (command == 'watch') {
    if (!event) {
      debugLog("can't watch without an event",3)
      return
    } else if (!callback) {
      debugLog("can't watch without a callback",3)
      return
    } else {
      watcher[ref][event] = callback
    }
  } else {
    if (!event)
      for (event in watcher[ref])
        watcher[ref][event] = undefined
    else
      watcher[ref][event] = undefined
  }
}
function watchGo(ref, event) { // checks for an event callback and executes it, then unwatches it
  debugLog("executing watch for '"+ref+"', event '"+event+"'",3)
  if (ref == null || ref == undefined) {
    debugLog("ajax without ref "+event+"d. hope it wasn't supposed to be watched",3)
    return
  } else if (watcher[ref] == undefined) {
    debugLog("ref isn't being watched",3)
    return
  }
  
  if (watcher[ref][event]) {
    eval(watcher[ref][event])
    watchReg(ref,'unwatch',event,null)
  }
}
function datesPulled(g,s,e) {
  debugLog('asking if group '+g+' has dates pulled from '+s+' to '+e,0)
  a = false
  $.each(dates_pulled[g],function(i,el) {
    if (el[0]<=s&&el[1]>=e)
      a = true
  })
  debugLog(a,0)
  return a
}
function debugLog(s,l) {
  if (calDebug && (l == undefined || debugLevel <= l)) console.log(s)
}
function errorLog(s) {
  $.colorbox({html:"<h1>Oops!</h1>"+s,inline:false,width:'400px'})
}
