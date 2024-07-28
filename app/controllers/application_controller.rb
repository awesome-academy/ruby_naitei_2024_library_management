class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pagy::Backend
  before_action :set_locale
  before_action :set_layout
  before_action :set_categories

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

  def set_categories
    @categories = Category.includes(:subcategories).no_parent_category
  end
end
