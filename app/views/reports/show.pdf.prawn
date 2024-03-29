prawn_document do |pdf|
    pdf.font "Helvetica"

    pdf.define_grid(columns: 5, rows: 8, gutter: 10)

    pdf.grid([0,0],[2,1]).bounding_box do
      pdf.image File.open(@report.group.image.path), width: 100, height: 100
    end

    pdf.grid([0,1],[1,2]).bounding_box do
      @report.group.positions.includes(:role).where("roles.name = 'Production Staff'").sort.each do |p|
        pdf.text "#{p.display_name}: #{p.user}", size: 8
      end
    end

    pdf.grid([0.5,3],[1,4]).bounding_box do
      pdf.text @report.report_template.name, size: 24, style: :bold
      pdf.text @report.sub_heading, size: 14
      pdf.text @report.sub_heading2, size: 12
    end

    pdf.stroke_horizontal_rule
    pdf.move_down 10

    @report.report_template.report_fields.each do |rf|
      pdf.text rf.name, size: 12, style: :bold
      rv = @report.report_values.where(report_field_id: rf.id).first
      if rf.field_type == 'section'
        if rv && rv.value.length > 0
          pdf.text rv.value, size: 10
        else
          pdf.text rf.default_value, size: 10
        end
      elsif rf.field_type == 'taggedtext'
        pdf.text rf.parsed_value(@group), size: 10
      end
      pdf.move_down 10
    end

    pdf.page_count.times do |i|
      pdf.go_to_page(i+1)
      pdf.grid([7.8,0],[8,3.5]).bounding_box do
        pdf.image Rails.root.join('app/assets/images/sns_web_logo.png'), height: 30, width: 180
      end
      pdf.grid([7.98,3.5],[8,5]).bounding_box do
        pdf.text "Created by #{@report.creator}", size: 10
      end
    end
end
