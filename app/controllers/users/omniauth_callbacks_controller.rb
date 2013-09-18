class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    unless current_user
      @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

      if @user && @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:notice] = "#{request.env["omniauth.auth"].to_s}"
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    else
      redirect_to root_path
    end
  end
end
