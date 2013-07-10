module Shared
  module AttachmentHelper
    class << self
      def included(base)
        base.extend ClassMethods
      end
    end

    module ClassMethods
      Paperclip.interpolates :urlpath do |attachment, style|
        filename = attachment.options[:file_name]

        if Rails.env.development? && File.exists?("/system/#{filename}")
          "/system/#{filename}"
        else
          "http://upload.snstheatre.org/scotch/#{filename}"
        end
      end

      def has_attachment(name, options = {})
        options[:url] ||= ":urlpath"
        has_attached_file(name, options)
      end
    end
  end
end
