module TextHelper
  def textilize(text)
    text = filter_referrals(text)
    text = text.gsub(/\n/,"<br>")
    super(text)
  end
  
  def textilize_without_paragraph(text)
    text = filter_referrals(text)
    text = text.gsub(/\n/,"<br>")
    super(text)
  end
  
  def filter_referrals(text)
    return nil if text.nil?
    return '' if text.blank?
    
    text = basic_referrals(text)
    text = user_referrals(text)
    raw(text)
  end
  def user_referrals(text)
    matches = text.scan(/\@([a-z]+)/)
    matches.each do |match|
      user = User.find_by_andrewid(match)
      text.gsub!("@#{match}", link_to(user.to_s, user)) unless user.nil?
    end
    raw(text)
  end
  def basic_referrals(text)
    # the first/most prevalent syntax should be
    # "#{obj.class.to_s}##{obj.id}"
    # we don't want to use object_id since it's not findable
    typeRegex = /Checkout|Document|User|Group|Event|HelpItem|Item/i
    matches = text.scan(/#{typeRegex}\#[\d]+/)
    matches.each do |match|
      classname = match[0...1].upcase+match[1...match.index('#')].downcase
      id = match[match.index('#')+1..-1]
      
      begin
        objclass = Kernel.const_get classname
      rescue NameError
        # ignore thing that doesn't match
        # since we can't find it to validate
        next
      end
      
      obj = objclass.find_by_id(id)
      # ignore thing we can't find
      # since we can't find it to validate
      next if obj.nil?
      
      # this part assumes that all REFERRABLE classes
      # implement a smarter "to_s" than Object's
      text.gsub!(match, link_to(obj.to_s, obj))
    end
    
    raw(text)
  end
end
