class CustomFailure < Devise::FailureApp
  def redirect
    store_location!
    flash[:alert] = i18n_message unless flash[:notice]
    if i18n_message == I18n.t("devise.failure.unconfirmed")
      redirect_to new_user_confirmation_path
    #elsif i18n_message == I18n.t("devise.failure.unauthenticated")
    #elsif i18n_message == I18n.t("devise.failure.locked")
    #elsif i18n_message == I18n.t("devise.failure.invalid")
    #elsif i18n_message == I18n.t("devise.failure.invalid_token")
    #elsif i18n_message == I18n.t("devise.failure.timeout")
    #elsif i18n_message == I18n.t("devise.failure.inactive")
    else
      redirect_to new_user_session_path
    end
  end
end
