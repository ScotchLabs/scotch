class UniqueSlugValidator < ActiveModel::EachValidator
  # this validator makes sure that an object's "slug" is unique, since slug is often
  # a method and not an attribute.
  # call it on the attribute that is primary in creating the slug.
  # example: for ItemCategory, this validation is used on :prefix,
  # since an item_category's slug is built from its prefix.
  def validate_each(object, attribute, value)
    # if the object has no slug, return instead of error
    return if !object.respond_to? "slug"
    
    # object's slug is nil and is not allowed to be
    if object.slug.nil? and !options[:allow_nil]
      object.errors[attribute] << "makes for a nil slug"
    end
    
    # object's slug is blank and is not allowed to be
    if object.slug.blank? and !options[:allow_blank]
      object.errors[attribute] << "makes for a blank slug"
    end
    
    # Another object of the same class has a slug with this value
    if object.class.all.map {|ic| ic.slug }.compact.include? object.slug
      object.errors[attribute] << (options[:message] || "makes for a nonunique slug")
    end
  end
end
