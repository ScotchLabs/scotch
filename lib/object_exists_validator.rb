class ObjectExistsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (value.nil? and !options[:allow_nil]) or (value.blank? and !options[:allow_blank])
      record.errors[attribute] << "is nil or blank"
    elsif value.nil? or value.blank?
      # we must have allowed it to be nil or blank
    elsif !attribute.to_s.include? "_id"
      # they used this validator on something that wasn't a proper pointer attribute
    else
      # check for object
      objstr = attribute.to_s[0...attribute.to_s.length-3]
      if !record.respond_to? objstr
        # record does not belong_to object
      else
        obj = record.instance_eval objstr
        puts "DEBUG record is #{record.to_s}, objstr is #{objstr}, obj is #{obj.to_s}"
        record.errors[attribute] << "does not point to a valid object" if obj.nil?
      end
    end
  end
end