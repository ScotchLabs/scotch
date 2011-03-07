var selectedGroups = []
var group_positions = {}
var cachedEvents = {}
var calDebug = true
var obj
var ajax = {}

$(document).ready(function() {
  // populate selectedGroups
  $.each($(".groupButton[selected=true]"), function(i, item) { selectedGroups.push(parseInt($(item).attr('id'))) })
  
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    allDayDefault: false,
    dayClick: function(date, allDay, jsEvent, view) {
      // http://arshaw.com/fullcalendar/docs/mouse/dayClick/
      newEvent(null, date, allDay)
    },
    eventClick: function(event, jsEvent, view) {
      // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
      html = "<h1>"+event.title+"</h1>"+
        "<h2>"+event.group+"</h2>"
      if (!event.allDay) {
        html += "<b>Starts</b>: "+event.start+"<br>"+
          "<b>Ends</b>: "+event.end+"<br>"
      } else
        html += "All day "+event.start+"<br>"
      html+= "<b>Where</b>: "+event.location+"<br>"
      if (event.attendees == undefined) {
        html+= "<b>Attendees</b>: <span id='attendees_"+event.id+"'></span><img alt=\"Indicator\" id=\"attendeesloading_"+event.id+"\" src=\"/images/indicator.gif\">"
        $.ajax({
          url: '/events/'+event.id+'/event_attendees.json',
          success: function(data) {
            $("#attendeesloading_"+data.event_id).hide()
            a = attendees_to_str(data.attendees)
            cachedEvents[data.event_id].attendees = a
            $("#attendees_"+data.event_id).html(a)
          },
          error: function(xhr, status, thrown) {
            if (calDebug) console.log('attendees for event failed to load. status '+status+', thrown '+thrown)
          }
        })
      } else {
        html += "<b>Attendees</b>: "+event.attendees
      }
      
      $.colorbox({html:html,inline:false,width:"400px",height:"400px"})
    },
    events: function(start, end, callback) {
      eventIds = []
      
      for (i in selectedGroups) {
        events = []
        group_id = selectedGroups[i]
        foundCache = false
        //FIXME traverse cache
        for (j in cachedEvents) {
          if (cachedEvents[j]["group_id"] != group_id) continue
          else foundCache = true
        }
        
        if (!foundCache) {
          $("#grouploading_"+group_id).show()
          url = '/groups/'+group_id+'/events.json'
          if (calDebug) console.log("pulling "+group_id+" events from "+url)
          ajax[group_id] = $.ajax({
            url: url,
            success: function(data) {
              if (calDebug) console.log('success')
              $.each(data.events, function(k) {
                if ($.inArray(data.events[k].id, eventIds) == -1) {
                  events.push(data.events[k])
                  eventIds.push(data.events[k].id)
                }
                cachedEvents[data.events[k].id] = data.events[k]
              })
              for (m in events)
                $("#calendar").fullCalendar('renderEvent',events[m])
              $("#grouploading_"+data.group_id).hide()
            },
            error: function(xhr, status, thrown) {
              //TODO hide loading
              if (calDebug) console.log('error. status: '+status+', thrown: '+thrown)
              //TODO show error
            }
            
          })
        } else {
          $("#grouploading_"+group_id).show()
          if (calDebug) console.log('pulling '+group_id+' events from cache')
          //FIXME traverse cache
          for (l in cachedEvents) {
            item = cachedEvents[l]
            if (item["group_id"] != group_id)
              continue
            if ($.inArray(item.id, eventIds) == -1) {
              if (calDebug) console.log('pushing event from cache')
              events.push(item)
              eventIds.push(item.id)
            }
          }
          for (n in events)
            $("#calendar").fullCalendar('renderEvent',events[n])
          $("#grouploading_"+group_id).hide()
        }
      }
    }
  })
  
  $(".fc-button-prev a, .fc-button-next a, .fc-button-today:not(.fc-state-disabled) a").click(function(){
    abortAllAjax()
    super
  })
  
  var dates = $("#event_start_time, #event_end_time").datepicker({
    timeFormat: 'h:mm',
    onSelect: function( selectedDate ) {
  		var option = this.id == "event_start_time" ? "minDate" : "maxDate",
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
  $("#event_stop_on_date").datepicker({
    showOn: "button",
    buttonImage: "/images/cal.png",
    buttonImageOnly: true
  })
  
  populateInvitees()
})
function abortAllAjax(){
  for (i in ajax) {
    if (ajax[i] == undefined)
      continue
    ajax[i].abort()
    if (calDebug) console.log('aborting request for '+i)
  }
  ajax = []
}

function toggle(group_id) {
  if (calDebug) console.log('toggling '+group_id)
  classes = $("#"+group_id).attr('class').split(' ')
  needle=/event_color_([0-9]+)/
  color = -1
  $.each(classes, function(i) {
    hay = classes[i]
    m = needle.exec(hay)
    if (m != null)
      color = m[1]
  })
  if (calDebug && color == -1) console.log('color not specified')
  if ($('#'+group_id).attr('selected')=='true') {
    if (calDebug) console.log('selected -> deselected')
    $('#'+group_id).attr('selected','false')
    $("#"+group_id).removeClass('event_color_'+color)
    $("#"+group_id).addClass('event_color_'+color+'_')
    $("#"+group_id).css("color","#333")
    selectedGroups.splice(selectedGroups.indexOf(group_id),1)
  } else {
    if (calDebug) console.log('deselected -> selected')
    $('#'+group_id).attr('selected','true')
    $("#"+group_id).removeClass('event_color_'+color+'_')
    $("#"+group_id).addClass('event_color_'+color)
    $("#"+group_id).css("color","#fff")
    selectedGroups.push(group_id)
  }
  $("#calendar").fullCalendar('refetchEvents')
}

function newEvent(group_id, date, allDay) {
  updateEventTimes(allDay)
    
  if (group_id != null) {
    $("#event_group_id option").removeAttr('selected')
    $("#event_group_id option[value='"+group_id+"']").attr('selected','selected')
    populateInvitees()
  }
  
  if (date) {
    $("#event_start_time").datetimepicker('setDate', date)
    if (allDay)
      date.setDate(date.getDate()+1)
    else
      date.setHours(date.getHours()+1)
    $("#event_end_time").datetimepicker('setDate', date)
  }
  
  $("#new_event").attr('action','/events.xml')
  
  $.colorbox({href:"#newEventForm"})
}

function updateEventTimes(allDay) {
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
function updateRepeat() {
  repeats = $("#_repeat").attr('checked')
  if (repeats) {
    $("#event_repeat_frequency").removeAttr('disabled')
    $("#event_repeat_period").removeAttr('disabled')
    $("#stop_condition_type_occurrences").removeAttr('disabled')
    $("#stop_condition_type_date").removeAttr('disabled')
  }
  repeatStopOn = $("[name='stop_condition_type']:checked").val()
  if (repeatStopOn == "occurrences")
    $("#event_stop_after_occurrences").removeAttr('disabled')
  else if (repeatStopOn == "date") {
    $("#event_stop_on_date").removeAttr('disabled')
    $("#_stop_on_time_4i").removeAttr('disabled')
    $("#_stop_on_time_5i").removeAttr('disabled')
    $("#repeat .at").css('color','#333')
  }
  if (repeatStopOn != "occurrences")
    $("#event_stop_after_occurrences").attr('disabled',true)
  if (repeatStopOn != "date") {
    $("#event_stop_on_date").attr('disabled',true)
    $("#_stop_on_time_4i").attr('disabled',true)
    $("#_stop_on_time_5i").attr('disabled',true)
    $("#repeat .at").css('color','#ddd')
  }
  if (!repeats) {
    $("#event_repeat_frequency").attr('disabled',true)
    $("#event_repeat_period").attr('disabled',true)
    $("#stop_condition_type_occurrences").attr('disabled',true)
    $("#stop_condition_type_date").attr('disabled',true)
    $("#event_stop_after_occurrences").attr('disabled',true)
    $("#event_stop_on_date").attr('disabled',true)
    $("#repeat .at").css('color','#ddd')
    $("#_stop_on_time_4i").attr('disabled',true)
    $("#_stop_on_time_5i").attr('disabled',true)
  }
}

function submit_event_form() {
  $("#position_names option").attr("selected",true)
  $("#new_event [type='submit']").attr('disabled',true)
  // show loading
  $.ajax({
    url: $("#new_event").attr('action'),
    type: "POST",
    data: $("#new_event").serialize(),
    success: function(data, status, xhr) {
      // put event in calendar or
      // highlight invalid fields
      obj = data
    },
    error: function(xhr, status, thrown) {
      if (calDebug) console.log('error submitting new event form. status '+status+', thrown '+thrown)
    },
    complete: function(xhr, status) {
      $("#new_event [type='submit']").removeAttr('disabled')
      // hide loading
    }
  })
  return false
}

function attendees_to_str(attendees) {
  a = ""
  for (i in attendees) {
    attendee = attendees[i]
    if (i==attendees.length-1 && i!=0)
      a += " and "
    else if (i!=0)
      a += ", "
    a+= attendee.name
  }
  if (a == "") a = "none listed"
  return a
}
function populateInvitees() {
  $("#position_names").empty()
  if (calDebug) console.log('populating invitees')
  positions = []
  html = ""
  group_id = parseInt($("#event_group_id").val())
  $.each(group_positions[group_id], function(i) {
    position = group_positions[group_id][i].position
    if ($.inArray(position.display_name, positions) == -1) {
      positions.push(position.display_name)
      html += "<option value=\""+position.display_name+"\">"+position.display_name+"</option>"
    }
  })
  $("#position_select").html(html)
}
function updatePrivacy() {
  pt = $("[name='event[privacy_type]']:checked").val()
  if (pt == 'limited')
    $("#event_attendee_limit").removeAttr('disabled')
  else
    $("#event_attendee_limit").attr('disabled',true)
}
