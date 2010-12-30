$(document).ready(function() {
  $('#calendar').fullCalendar({
    header: {right: 'month,agendaWeek prev,today,next'},
    defaultView: 'agendaWeek',
    lazyFetching: true
  })
  
  $("#mygroups .groupButton").each(function(){toggle($(this).attr('id'))})
})

function toggle(group_id) {
  url = '/groups/'+group_id+'/events.json'
  if ($('#'+group_id).attr('selected')=='true') {
    $('#'+group_id).attr('selected','false')
    console.log('removing source '+url)
    $('#calendar').fullCalendar('removeEventSource',url)
  } else {
    $('#'+group_id).attr('selected','true')
    console.log('adding source '+url)
    $('#calendar').fullCalendar('addEventSource',url)
  }
}
