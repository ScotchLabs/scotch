class ObjectExistsValidator < ActiveModel::EachValidator
  # this validator makes sure that the parent object of record exists
  # example: Items have an item_category_id, and they belong_to an item_category
  # we can validate that the id exists model-side, but what happens when the
  # id isn't pointing anywhere?
  # this validator makes sure that can't happen
  # call this validator on the xxx_id attribute to validate
  def validate_each(record, attribute, value)
    
    # id is blank or nil and is not allowed to be
    if (value.nil? and !options[:allow_nil]) or (value.blank? and !options[:allow_blank])
      record.errors[attribute] << "is nil or blank"
      
    # we must have allowed value to be nil or blank
    elsif value.nil? or value.blank?
      return
      
    # they used this validator on something that wasn't a proper pointer attribute
    elsif !attribute.to_s.include? "_id"
      return
      
    # should be an ok xxx_id attribute
    else
      
      # check for object
      objstr = attribute.to_s[0...attribute.to_s.length-3]
      
      # record doesn't actually belong_to xxx
      if !record.respond_to? objstr
        return
        
      else
        # actually pull up the object (through record's belongs_to)
        obj = record.instance_eval objstr
        record.errors[attribute] << "does not point to a valid object" if obj.nil?
      end
    end
  end
end