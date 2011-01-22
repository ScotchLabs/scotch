var selectedGroups = []
var cachedEvents = []

$(document).ready(function() {
  // populate selectedGroups
  $.each($(".groupButton[selected]"), function(i, item) { selectedGroups.push(parseInt($(item).attr('id'))) })
  
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    events: function(start, end, callback) {
      events = []
      for (i in selectedGroups) {
        group_id = selectedGroups[i]
        url = '/groups/'+group_id+'/events.json'
        
        foundCache = false
        for (j in cachedEvents) {
          if (cachedEvents[j]["id"] != group_id) continue
          else foundCache = true
        }
        
        if (!foundCache) {
          $.ajax({
            async: false,
            url: url,
            success: function(data) {
              $.each(data, function(j) {
                events.push(data[j])
              })
              cachedEvents.push({"id":selectedGroups[i],"json":data})
            }
            
            
          })
        }
        else {
          for (j in cachedEvents) {
            item = cachedEvents[j]
            if (item["id"] != selectedGroups[i])
              continue
            $.each(item["json"], function(k) {
              events.push(item["json"][k])
            })
          }
        }
      }
      
      callback(events)
    }
  })
})

function toggle(group_id) {
  console.log('toggling '+group_id)
  if ($('#'+group_id).attr('selected')=='true') {
    console.log('selected -> deselected')
    $('#'+group_id).attr('selected','false')
    selectedGroups.splice(selectedGroups.indexOf(group_id),1)
  } else {
    console.log('deselected -> selected')
    $('#'+group_id).attr('selected','true')
    selectedGroups.push(group_id)
  }
  $("#calendar").fullCalendar('refetchEvents')
}
