class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :set_locale
  before_action :set_layout

  private
  def set_layout
    self.class.layout current_account&.is_admin ? "admin" : "application"
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
