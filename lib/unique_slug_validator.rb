class UniqueSlugValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if !object.slug.nil? and object.class.all.map {|ic| ic.slug }.compact.include? object.slug
      object.errors[attribute] << (options[:message] || "makes for a nonunique slug")
    end
  end
end
