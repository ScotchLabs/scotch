var selectedGroups = []
var cachedEvents = []
var calDebug = true
var obj

$(document).ready(function() {
  // populate selectedGroups
  $.each($(".groupButton[selected=true]"), function(i, item) { selectedGroups.push(parseInt($(item).attr('id'))) })
  
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    events: function(start, end, callback) {
      events = []
      finishedGroups = []
      
      $("#calendar").ajaxComplete(function() {
        if (calDebug) console.log('ajax complete')
        if (finishedGroups.length == selectedGroups.length) {
          if (calDebug) console.log('calling back')
          callback(events)
        }
      })
      
      for (i in selectedGroups) {
        group_id = selectedGroups[i]
        allFromCache = true
        foundCache = false
        for (j in cachedEvents) {
          if (cachedEvents[j]["id"] != group_id) continue
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
              $("#grouploading_"+data.group).hide()
              if (calDebug) console.log('success')
              dataevents = data.events
              $.each(dataevents, function(k) {
                events.push(dataevents[k])
              })
              finishedGroups.push(data.group)
              cachedEvents.push({"id":data.group,"json":data.events})
            },
            error: function(xhr, status, thrown) {
              //TODO hide loading
              if (calDebug) console.log('error. status: '+status+', thrown: '+thrown)
              //TODO show error
            }
            
          })
        } else {
          if (calDebug) console.log('pulling '+group_id+' events from cache')
          for (l in cachedEvents) {
            item = cachedEvents[l]
            if (item["id"] != group_id)
              continue
            $.each(item["json"], function(m) {
              events.push(item["json"][m])
            })  
            finishedGroups.push(group_id)
          }  
        }
      }
      
      if (allFromCache) {
        if (calDebug) console.log('calling back')
        callback(events)
      }
    }
  })
})

function toggle(group_id) {
  if (calDebug) console.log('toggling '+group_id)
  if ($('#'+group_id).attr('selected')=='true') {
    if (calDebug) console.log('selected -> deselected')
    $('#'+group_id).attr('selected','false')
    selectedGroups.splice(selectedGroups.indexOf(group_id),1)
  } else {
    if (calDebug) console.log('deselected -> selected')
    $('#'+group_id).attr('selected','true')
    selectedGroups.push(group_id)
  }
  $("#calendar").fullCalendar('refetchEvents')
}
