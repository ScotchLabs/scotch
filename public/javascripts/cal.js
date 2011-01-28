var selectedGroups = []
var cachedEvents = {}
var calDebug = true
var obj

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
      events = []
      eventIds = []
      finishedGroups = []
      
      $("#calendar").ajaxComplete(function() {
        if (calDebug) console.log('ajax complete')
        if (finishedGroups.length == selectedGroups.length) {
          if (calDebug) console.log('calling back')
          $("#calendar").fullCalendar("removeEvents")
          callback(events)
        }
      })
      
      for (i in selectedGroups) {
        group_id = selectedGroups[i]
        allFromCache = true
        foundCache = false
        //FIXME traverse cache
        for (j in cachedEvents) {
          if (cachedEvents[j]["group_id"] != group_id) continue
          else foundCache = true
        }
        
        if (!foundCache) {
          allFromCache = false
          $("#grouploading_"+group_id).show()
          url = '/groups/'+group_id+'/events.json'
          if (calDebug) console.log("pulling "+group_id+" events from "+url)
          $.ajax({
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
              finishedGroups.push(data.group_id)
              $("#grouploading_"+data.group_id).hide()
            },
            error: function(xhr, status, thrown) {
              //TODO hide loading
              if (calDebug) console.log('error. status: '+status+', thrown: '+thrown)
              //TODO show error
            }
            
          })
        } else {
          if (calDebug) console.log('pulling '+group_id+' events from cache')
          //FIXME traverse cache
          for (l in cachedEvents) {
            item = cachedEvents[l]
            if (item["group_id"] != group_id)
              continue
            if ($.inArray(item.id, eventIds) == -1) {
              console.log('pushing event from cache')
              events.push(item)
              eventIds.push(item.id)
            }
            if ($.inArray(item.group_id, finishedGroups) == -1)
              finishedGroups.push(item.group_id)
          }  
        }
      }
      
      if (allFromCache) {
        if (calDebug) console.log('calling back')
        $("#calendar").fullCalendar("removeEvents")
        callback(events)
      }
    }
  })
})

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
  //TODO build or pull a form
  if (group_id == null)
    group_id = "no group"
  $.colorbox({href:"#newEventForm"})
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
  if (a == "") a = "none"
  return a
}
