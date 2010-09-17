class CreateAuthTokens < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.ensure_authentication_token
      u.save!
    end
  end

  def self.down
  end
end
