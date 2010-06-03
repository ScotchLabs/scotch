# Copyright (c) 2006 Marshall Roch, mroch@cmu.edu
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 

module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module PhoneNumber
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end
      
      module ClassMethods
        def acts_as_phone_number(*attributes)          
          attributes.each do |attr_name|
            # Remove non-digits and any leading 1's (US country code) before saving
            define_method("#{attr_name}=") do |value|
              write_attribute attr_name, value.gsub(/([^\d])/, '').gsub(/^1/, '')
            end
            
            # Use this to access the raw attribute value as stored in the database
            define_method("raw_#{attr_name}") do
              read_attribute(attr_name)
            end
            
            # This method is overridden to make text_fields show the formatted value
            define_method("#{attr_name}_before_type_cast") do
              read_attribute(attr_name).to_s.gsub(/^(\d{3})[^\d]*(\d{3})[^\d]*(\d{4})$/, '(\1) \2-\3')
            end
            
            define_method("#{attr_name}") do
              self.send "#{attr_name}_before_type_cast"
            end            
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::PhoneNumber
