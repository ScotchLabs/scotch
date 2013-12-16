module PositionsHelper

  # FIXME: unfilled is not DRY
  # Return a list of the positions for a show which are not currently filled
  def unfilled_tech_heads
    # We start with this nice array of position names
    primary_positions = [
      "Costume Designer", "Designer", "Hair & Makeup Designer", 
      "House Manager", "Lighting Designer", "Master Carpenter", 
      "Master Electrician", "Paint Charge", "Props Master", "Publicity Head",
      "Set Designer", "Sound Designer", "Sound Engineer"]

    return filter_unused(primary_positions)
  end

  def unfilled_production_staff
    # We start with this nice array of position names
    primary_positions = ["Choreographer", "Director", "Music Director",
      "Production Liaison", "Production Manager", "Stage Manager", 
      "Technical Director"]

    return filter_unused(primary_positions)
  end

  def crews
    crews = ["Lighting/Electrics", "Carpentry", "Sound", "Paint",
      "Publicity", "Props", "Hair/Makeup", "Costumes", "House Management", "Run"]
    return crews.collect{|c| c + " Crew"}
  end

  def render_position(pos)
    content_tag "p" do
      pos_label_color = "label-default"

      if pos.role.to_s == "Cast"
        pos_label_color = "label-success"
      elsif pos.role.to_s == "Tech Head"
        pos_label_color = "label-danger"
      elsif pos.role.to_s == "Production Staff"
        pos_label_color = "label-warning"
      end

      result = content_tag "span", class: "position-#{pos.role.short_name}" do
        "#{pos} "
      end

      result += content_tag "span", class: "label #{pos_label_color}" do
        pos.role.to_s
      end

      result.html_safe
    end
  end

  protected

  def filter_unused(positions)
    current_positions = @group.positions.group(:display_name).collect{|p| p.display_name}
    unused_positions = []

    positions.each do |p|
      if current_positions.include? p then
        unused_positions << ("Assistant " + p) unless current_positions.include? "Assistant " + p 
      else
        unused_positions << p
      end
    end

    return unused_positions
  end
end
