class Admin::BooksController < Admin::ApplicationController
  def index
    @pagy, @books = pagy Book.order_by_title, items: Settings.books_per_page
  end
end
