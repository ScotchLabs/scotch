class TagParser
  def self.parse_tags_for_group(input, group)
    parsed_result = input

    input.scan(/\[([^\[\]]*)\]/).each do |i|
      i = i.first
      parsed = i.split(':')
      result = ""
      
      case parsed[0]
      when 'positions'
        result = group.positions.where(display_name: parsed[1]).first.try(:user).try(parsed[2])
      end

      parsed_result.gsub!("[#{i}]", result)
    end

    return input
  end
end
