class ApplicationController < ActionController::Base
  layout "application"
  include SessionsHelper
  include Pagy::Backend
  include CanCan::ControllerAdditions

  before_action :set_locale
  before_action :set_categories
  before_action :set_current_user

  def is_admin_role?
    return if current_account&.is_admin

    flash[:error] = t "noti.permission_err"
    redirect_to root_path
  end

  def current_ability
    @current_ability ||= Ability.new current_account
  end

  rescue_from CanCan::AccessDenied do |_exception|
    if current_account.nil?
      store_location
      flash[:danger] = t "noti.sign_in_first"
      redirect_to login_path
    else
      flash[:danger] = t "noti.permission_err"
      redirect_to request.referer
    end
  end

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def set_categories
    @categories = Category.includes(:subcategories).no_parent_category
    @current_category = Category.find_by(id: params[:category])
  end

  def set_current_user
    @current_user = current_account&.user if current_account
  end
end
