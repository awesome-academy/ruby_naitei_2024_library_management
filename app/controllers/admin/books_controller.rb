class Admin::BooksController < Admin::ApplicationController
  before_action :load_book, only: %i(destroy)
  def index
    @pagy, @books = pagy Book.order_by_title, items: Settings.books_per_page
  end

  def destroy
    if @book.destroy
      flash[:success] = t "noti.book_delete_success"
    else
      flash[:danger] = t "noti.book_delete_fail"
    end
    redirect_to admin_books_path
  end

  private
  def load_book
    @book = Book.find_by(id: params[:id])
    return if @book

    flash[:danger] = t "noti.book_not_found"
    redirect_to books_path
  end
end
