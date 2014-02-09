$(document).ready(function() {
  $('.events-calendar').fullCalendar({
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'agendaWeek,agendaDay'
    },
    events: 'events.json',
    defaultView: 'agendaWeek'
  });
});
