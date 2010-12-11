class FixInventory < ActiveRecord::Migration
  def self.up
    items = ["000-002", "000-003", "000-004", "000-005", "000-006", "000-007", "000-008", "000-009", "000-010", "000-011", "000-012", "000-013", "000-014", "000-015", "000-016", "000-017", "000-018", "000-019", "000-020", "000-021", "000-022", "000-023", "000-024", "000-025", "000-026", "000-028"]
    for cat in items
      item = Item.find_by_catalog_number(cat)
      next if item.nil?
      ic = ItemCategory.find_all_by_prefix(cat.slice(0,1)).select{|el| el.parent_category.nil?}[0]
      next if ic.nil?
      isc = ic.item_subcategories.select{|el| el.prefix == cat.slice(1,3).to_i}[0]
      next if isc.nil?
      item.item_category_id = isc.id
      item.save!
      #puts "#{item.name} is changing from #{item.item_category.name} to #{isc.name}"
    end
  end

  def self.down
  end
end
