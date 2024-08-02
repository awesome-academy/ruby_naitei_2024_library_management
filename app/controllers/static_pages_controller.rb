class StaticPagesController < ApplicationController
  def home
    flash.now[:success] = t "noti.welcome"
    @book_series = BookSeries.order_by_time
    @categories_with_books = Category.get_books
  end
end
