class UniqueSlugValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if !object.slug.nil? and ItemCategory.all.map {|ic| ic.slug }.compact.include? value
      object.errors[attribute] << (options[:message] || "makes for a nonunique slug")
    end
  end
end