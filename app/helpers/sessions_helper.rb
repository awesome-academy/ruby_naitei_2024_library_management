module SessionsHelper
  def log_in account
    session[:account_id] = account.id
    session[:user_id] = account.user&.id
  end

  def current_user
    current_account&.user
  end

  def current_account
    if account_id = session[:account_id]
      @current_account ||= Account.find_by id: account_id
    elsif account_id = cookies.signed[:account_id]
      account = Account.find_by id: account_id
      if account&.authenticated? :remember, cookies[:remember_id]
        log_in account
        @current_account = account
      end
    end
  end

  def logged_in?
    current_account&.user.present?
  end

  def authenticate_user
    return if logged_in?

    store_location
    flash[:danger] = t "noti.sign_in_first"
    redirect_to login_path, status: :see_other
  end

  def authenticate_account
    return if current_account.present?

    store_location
    flash[:danger] = t "noti.sign_in_first"
    redirect_to login_path, status: :see_other
  end

  def forget account
    account.forget
    cookies.delete :user_id
    cookies.delete :remember_id
    cookies.delete :account_id
  end

  def log_out
    forget current_account
    session.delete :user_id
    session.delete :remember_id
    session.delete :account_id
    @current_user = nil
    @current_account = nil
  end

  def remember account
    account.remember
    cookies.permanent[:remember_id] = account.remember_id
    cookies.permanent.signed[:user_id] = account.user&.id
  end

  def current_user? user
    user == current_user
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
