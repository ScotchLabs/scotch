prawn_document do |pdf|
    pdf.font "Helvetica"

    pdf.define_grid(columns: 5, rows: 8, gutter: 10)

    pdf.grid([0,0],[2,1]).bounding_box do
      pdf.image report.group.image, width: 100, height: 100
    end

    pdf.grid([0,1],[1,2]).bounding_box do
      report.group.positions.includes(:role).where("roles.name = 'Production Staff'").sort.each do |p|
        pdf.text "#{p.display_name}: #{p.user}"
      end
      pdf.text "Production Manager: Aaron Gross", size: 8
      pdf.text "Director: Sean Salamon", size: 8
      pdf.text "Stage Manager: Katie Humbert", size: 8
    end

    pdf.grid([0.5,3],[1,4]).bounding_box do
      pdf.text "Rehearsal Report", size: 24, style: :bold
      pdf.text "Saturday, October 28, 2012", size: 14
      pdf.text "PH 125C", size: 12
    end

    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text "TODAY'S SCHEDULE:", size: 12, style: :bold
    pdf.text "6:00-7:00 Act 1\n7:00-7:15 Break\n7:15-8:00 Act 2", size: 10

    pdf.move_down 10

    pdf.text "NEXT REHEARSAL: ", size: 12, style: :bold
    pdf.text "Monday, October 31 at 8:00pm in PH 125C", size: 10

    pdf.move_down 10

    pdf.text "GENEREAL NOTES: ", size: 12, style: :bold
    pdf.text "1. Late: Bob Smith\n2. Excused: John Doe", size: 10

    pdf.move_down 10

    pdf.text "PROPS NOTES: ", size: 12, style: :bold
    pdf.text "1. Can we get swords for rehearsal?", size: 10

    pdf.move_down 10

    pdf.text "SCENIC NOTES: ", size: 12, style: :bold
    pdf.text "1. None", size: 10

    pdf.move_down 10

    pdf.text "COSTUMES NOTES: ", size: 12, style: :bold
    pdf.text "1. None", size: 10

    pdf.move_down 10

    pdf.text "LIGHTING NOTES: ", size: 12, style: :bold
    pdf.text "1. None", size: 10

    pdf.move_down 10

    pdf.text "SOUND NOTES: ", size: 12, style: :bold
    pdf.text "1. None", size: 10

    pdf.move_down 10

    pdf.text "PRODUCTION MANAGEMENT: ", size: 12, style: :bold
    pdf.text "1. None", size: 10

    pdf.move_down 10

    pdf.text "Questions? Comments? Contact Stage Management", size: 12, style: :bold
    pdf.text "Stage Manager - Carlos Diaz-Padron <cdiazpad@andrew.cmu.edu>", size: 10

    pdf.page_count.times do |i|
      pdf.go_to_page(i+1)
      pdf.grid([7.8,0],[8,5]).bounding_box do
        pdf.image File.expand_path('../../Downloads/sns_web_logo.png', __FILE__), height: 30, width: 180
      end
    end
end
