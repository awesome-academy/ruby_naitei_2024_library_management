class StaticPagesController < ApplicationController
  def home
    flash.now[:success] = t "noti.welcome"
    @book_series = BookSeries.order_by_time
    @categories_with_books = Category.get_books
    @favourite_books = current_user&.favourite_books&.order_by_title
  end

  def account_banned?
    current_user&.account&.ban?
  end
end
