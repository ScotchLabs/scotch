require 'digest/whirlpool'

module Devise
  module Models
    module DatabaseAuthenticatable
      alias_method :bcrypt_valid_password?, :valid_password?

      def valid_password?(password)
        if self.password_salt.length == 32
          str = [self.password_salt, password].flatten.compact.join
          if ::Digest::Whirlpool.hexdigest(str) == self.encrypted_password
            ## authenticated; now convert to bcrypt password
            self.password = password
            self.save(false)
            return true
          else
            ## so that we don't get a bcrypt invalid hash exception
            return false
          end
        else
          bcrypt_valid_password?(password)
        end            
      end
    end
  end
end
