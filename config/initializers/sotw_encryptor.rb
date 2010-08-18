require 'digest/whirlpool'

module Devise
  module Encryptors
    class Sotw < Bcrypt
      def self.digest(password, stretches, salt, pepper)
        if salt.length == 32 then # SOTW encryption
          str = [salt, password].flatten.compact.join
          return Digest::Whirlpool.hexdigest(str)
        else #bzip encryption
          super(password, stretches, salt, pepper)
        end
      end
    end
  end
end
