var selectedGroups = []

$(document).ready(function() {
  // populate selectedGroups
  $.each($(".groupButton[selected]"), function(i, item) { selectedGroups.push(parseInt($(item).attr('id'))) })
  
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    lazyFetching: true,
    events: function(start, end, callback) {
      events = []
      for (i in selectedGroups) {
        url = '/groups/'+selectedGroups[i]+'/events.json'
        $.ajax({
          async: false,
          url: url,
          success: function(data) {
            $.each(data, function(j) {
              events.push(data[j])
            })
          }
        })
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
