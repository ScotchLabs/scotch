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
      res = request.env["omniauth.auth"].credentials
      current_user.update_attributes(google_access_token: res.token, google_refresh_token: res.refresh_token)

      flash[:notice] = "Successfully linked Google account!"

      redirect_to current_user
    end
  end
end
