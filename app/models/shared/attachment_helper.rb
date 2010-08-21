module Shared
  module AttachmentHelper
    class << self
      def included(base)
        base.extend ClassMethods
      end
    end

    module ClassMethods
      def has_attachment(name, options = {})
				now = Time.now
				# make up a filename if we weren't given one
				filename = options[:file_name] or "#{now.to_i}#{now.usec}_:style.:extension"

        if Rails.env.production?
					options[:path]	||= "/data/upload/scotch/#{filename}"
					options[:url]		||= "http://upload.snstheatre.org/scotch/#{filename}"
        else
          options[:path]  ||= ":rails_root/public/system/#{filename}"
          options[:url]   ||= "/system/#{filename}"
        end

        # pass things off to paperclip.
        has_attached_file name, options
      end
    end
  end
end
