var selectedGroups = []
var cachedEvents = []
var calDebug = true

$(document).ready(function() {
  // populate selectedGroups
  $.each($(".groupButton[selected=true]"), function(i, item) { selectedGroups.push(parseInt($(item).attr('id'))) })
  
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    events: function(start, end, callback) {
      events = []
      for (i in selectedGroups) {
        group_id = selectedGroups[i]
        
        foundCache = false
        for (j in cachedEvents) {
          if (cachedEvents[j]["id"] != group_id) continue
          else foundCache = true
        }
        
        if (!foundCache) {
          $("#grouploading_"+group_id).show()
          if (calDebug) console.log("pulling "+group_id+" events from ajax")
          $.ajax({
            async: false,
            url: '/groups/'+group_id+'/events.json',
            success: function(data) {
              if (calDebug) console.log('success')
              $.each(data, function(k) {
                events.push(data[k])
              })
              cachedEvents.push({"id":group_id,"json":data})
            },
            error: function() {
              if (calDebug) console.log('error')
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
          }
        }
      }
      
      callback(events)
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
