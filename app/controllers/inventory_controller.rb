class InventoryController < ApplicationController
  def index
  end

  def search
    if :query.nil? or :query.blank?
      # if :query does not exist redirect to index
      flash[:notice] = "Query did not exist."
      redirect_to "inventory#index"
    end
    #TODO-spencer
  end

  def browse
    if :cat.nil? or :cat.blank? or !(/[0-9]{3}/ === :cat)
      # if :cat does not exist or is not a number redirect to index
      flash[:notice] = "Category was blank or invalid."
      redirect_to "inventory#index"
    else
      item_category_slug = :cat.to_s[0..0]
      item_category = ItemCategory.find_by_prefix(item_category_slug)
      if item_category.nil?
        flash[:notice] = "Item Category does not exist."
        redirect_to "inventory#index"
      end
      item_subcategory_slug = :cat.to_s[1..2].to_i
      item_subcategory = ItemSubcategory.find_by_infix(item_subcategory_slug, :conditions => "item_category_id = #{item_category.id}")
      if item_subcategory_slug.nil?
        flash[:notice] = "Item Subcategory does not exist."
        redirect_to "inventory#index"
      end
      @items = Item.all(:conditions => "item_subcategory_id = #{item_subcategory.id}")
    end
  end

  def item
    if :slug.nil? or :slug.blank? or !(/[0-9]{3}\-[0-9]{3}/ === :slug)
      # if :slug does not exist or is invalid redirect to index
      flash[:notice] = "Item id was blank or invalid."
      redirect_to "inventory#index"
    else
      item_category_slug = :slug.to_s[0..0]
      item_category = ItemCategory.find_by_prefix(item_category_slug)
      if item_category.nil?
        flash[:notice] = "Item Category does not exist."
        redirect_to "inventory#index"
      end
      item_subcategory_slug = :slug.to_s[1..2].to_i
      item_subcategory = ItemSubcategory.find_by_infix(item_subcategory_slug, :conditions => "item_category_id = #{item_category.id}")
      if item_subcategory_slug.nil?
        flash[:notice] = "Item Subcategory does not exist."
        redirect_to "inventory#index"
      end
      item_slug = :slug.to_s[4..6].to_i
      @item = Item.find_by_catalog_number(item_slug, :conditions => "item_subcategoy_id = #{item_subcategory.id}")
    end
  end
  
  def newitem
    if request.post?
      # process the new item
    end
  end

end
