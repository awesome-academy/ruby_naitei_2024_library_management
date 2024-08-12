class StaticPagesController < ApplicationController
  before_action :check_account_status, only: %i(home)
  def check_account_status
    return unless current_account &&
                  @current_user.blank? && !current_account.is_admin

    flash[:warning] = t "noti.user_infor_404"
    redirect_to new_user_path
  end

  def home
    @book_series = BookSeries.order_by_time
    @categories_with_books = Category.get_books
    @favourite_books = @current_user&.favourite_books&.order_by_title
  end

  def account_banned?
    @current_user&.account&.ban?
  end
end
