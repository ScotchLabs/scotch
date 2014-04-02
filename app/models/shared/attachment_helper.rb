module Shared
  module AttachmentHelper
    class << self
      def included(base)
        base.extend ClassMethods
      end
    end

    module ClassMethods
      def has_attachment(name, options = {})
        options[:storage] = :s3
        options[:s3_credentials] = Rails.root.join('config', 'aws-config.yml')
        options[:bucket] = "sns-scotch"
        has_attached_file(name, options)
      end
    end
  end
end
