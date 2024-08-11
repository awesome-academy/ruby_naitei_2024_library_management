module SessionsHelper
  def logged_in?
    @current_user.present?
  end

  def authenticate_user
    return if logged_in?

    store_location
    flash[:danger] = t "noti.sign_in_first"
    redirect_to new_account_session_path, status: :see_other
  end

  def authenticate_account
    return if current_account.present?

    store_location
    flash[:danger] = t "noti.sign_in_first"
    redirect_to new_account_session_path, status: :see_other
  end

  def current_user? user
    user == @current_user
  end

  def store_location
    if request.get?
      session[:forwarding_url] = request.original_url
    elsif request.referer.present?
      session[:forwarding_url] = request.referer
    end
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete(:forwarding_url)
  end
end
