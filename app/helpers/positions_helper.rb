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

    all_positions = []
    # Now, we add in the assistants
    primary_positions.each{|s| 
      all_positions << s
      all_positions << "Assistant " + s
    }

    return filter_unused(all_positions)
  end

  def unfilled_production_staff
    # We start with this nice array of position names
    primary_positions = ["Choreographer", "Director", "Music Director",
      "Production Liaison", "Production Manager", "Stage Manager", 
      "Technical Director"]

    all_positions = []
    # Now, we add in the assistants
    primary_positions.each{|s| 
      all_positions << s
      all_positions << "Assistant " + s
    }

    return filter_unused(all_positions)
  end

  def crews
    crews = ["Lighting/Electrics", "Carpentry/Set design", "Sounds", "Paint",
      "Publicity", "Props", "Hair/Makeup", "Costumes", "House Management"]
    return crews.collect{|c| c + " Crew"}
  end

  protected

  def filter_unused(positions)
    # FIXME: this could be made much more efficient by finding the unique
    # positions and subtracting from all_positions
    return positions.select { |s|
      @group.positions.where(:display_name => s).count == 0
    }
  end
end
