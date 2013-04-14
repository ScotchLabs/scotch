prawn_document do |pdf|
  pdf.font "Courier"
  first = false
  @roster.each do |k, v|
    if first
      pdf.start_new_page(layout: :portrait)
    else
      first = true
    end

    pdf.text k, align: :center, size: 48
    data = [["Name", "Present?"]]

    v.each do |v|
      data << [v.user.name, "       "]
    end

    pdf.table(data, header: true) do |table|
      table.column_widths= [200, 120]
    end
  end
end
