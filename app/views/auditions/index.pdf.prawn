prawn_document do |pdf|
  pdf.font "Courier"
  pdf.text "Audition Sheet", align: :center, size: 48
  pdf.text "For Stage Manager Use", align: :center, size: 22
  first = false
  @auditions.each_key do |key|
    if first
      pdf.start_new_page(layout: :portrait)
    else
      first = true
    end

    pdf.text @auditions[key].first.start_time.strftime("%A, %B %-d")

    data = [["Name", "Time", "Phone Number"]]
    @auditions[key].each do |a|
      data << [a.users.first.name, a.start_time.strftime("%l:%M %p"), (a.users.first.phone || "Please Retrieve!")] if a.event_attendees.count > 0
    end

    pdf.table(data, header: true) do |table|
      table.column_widths = [200, 120, 180]
    end
  end
end
