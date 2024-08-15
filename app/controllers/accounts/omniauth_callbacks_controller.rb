class Accounts::OmniauthCallbacksController < ApplicationController
  def google_oauth2
    @account = Account.from_omniauth(request.env["omniauth.auth"])
    if @account.persisted?
      handle_successful_authentication
    else
      handle_failed_authentication
    end
  end

  def failure
    flash[:alert] = t "devise.omniauth_callbacks.failure"
    redirect_to root_path
  end

  private

  def handle_successful_authentication
    flash[:notice] =
      I18n.t "devise.omniauth_callbacks.success", kind: "Google"
    sign_in_and_redirect @account, event: :authentication
  end

  def handle_failed_authentication
    session["devise.google_data"] =
      request.env["omniauth.auth"].except(:extra)
    redirect_to new_account_registration_url,
                alert: @account.errors.full_messages.join("\n")
  end
end
