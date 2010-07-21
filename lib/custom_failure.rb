class CustomFailure < Devise::FailureApp
  def redirect
    store_location!
    flash[:alert] = i18n_message unless flash[:notice]
    redirect_to new_user_confirmation_path
  end
end