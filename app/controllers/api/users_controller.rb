class Api::UsersController < Api::BaseController
  doorkeeper_for :all
  respond_to :json

  def verify_credentials
    respond_with current_user
  end
end
