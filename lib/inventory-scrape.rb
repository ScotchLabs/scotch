# 1) dump phpMyAdmin's inventory table to xml
# 2) doctor the dump a fair amount (~10 find/replaces. could be ~3 if I try to be wittier)
#   these find-replaces mostly consist of removing unwanted tags and renaming other tags
#   they also consist of cleaning up all the instances of &amp;&quot; into \"
#FILEOUT db/inventory.xml
# 3) add nokogiri (http://nokogiri.org/) to the Gemfile
# 4) run these commands from the rails console:

# note: often in these commands I'll put "; nil" at the end.
# this is to prevent the console from getting overexcited about printing values

# open the file, nokogirify it
file = File.open "client/inventory.xml"; nil
doc = Nokogiri::XML file; nil
file.close

@items = Array.new

# calling @ic[some-category-slug] will return the id of the category
@ic = Hash.new
ItemCategory.all.each { |i| @ic[i.slug] = i.id }; nil

# for each node in the document matching
# the css query 'item'
doc.css('item').each do |node|
  
  # we have to pull out the catalog number
  itemnum = node.css("catalog-number").children[0].to_s
  catnum = itemnum[0..2]
  
  #  and look up the associated ItemCategory
  item_category_id = @ic[catnum]
  if item_category_id.nil?
    puts "oops! item #{itemnum} had a problem: couldn't find the category"
    next
  end
  
  # then we put the ItemCategory in the Item
  node.add_child "<item-category-id type=\"integer\">#{item_category_id.to_i}</item-category-id>"
  
  # and create a new Item from the record
  item = Item.new.from_xml node.to_s
  
  # and save it to the array
  @items << item
end

# we now have a populated array, let's output to xml
# the benefit here is that it includes item_category_ids
# and is guaranteed to be not less clean than the input
#FILEOUT db/items.xml
file = File.open("db/items.xml",'w')
file << @items.to_xml
file.close

# for added functionality, let's parse @items as seeds
#FILEOUT db/item_seeds.rb
@figurineText = ""
@items.each do |item|
  name = item.name.gsub '"', '\"'
  unless item.description.nil?
    description = item.description.gsub '
', '\n'
  end
  @figurineText << "i = Item.create(:name => \"#{name}\", :location => \"#{item.location}\", :description => \"#{description}\", :item_category_id => #{item.item_category_id}, :catalog_number => \"#{item.catalog_number}\")\n"
end
file = File.open "db/item_seeds.rb", "w"
file.write @figurineText
file.close

# finally, go through the seeds and do some weird unslashing,
# then copy the contents of item_seeds.rb to seeds.rb
# and wrap them in "Item.transaction do ... end"
