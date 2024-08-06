class StaticPagesController < ApplicationController
  def home
    if account_banned?
      handle_banned_account
    else
      flash.now[:success] = t "noti.welcome"
    end
    @book_series = BookSeries.order_by_time
    @categories_with_books = Category.get_books
  end

  private

  def account_banned?
    current_user.account.ban?
  end

  def handle_banned_account
    flash.now[:danger] = t("noti.banned_message")
  end
end
