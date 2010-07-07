class ItemCategorySlugValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if !value.nil? and ItemCategory.all.map {|ic| ic.slug }.compact.include? value
      object.errors[attribute] << (options[:message] || "That slug already exists")
    end
  end
end