class FavouritesController < ApplicationController
  authorize_resource
  include SessionsHelper
  before_action :find_book, only: %i(create)

  def index
    @pagy, @favourite_books = pagy @current_user.favourite_books
    @total_books = @favourite_books.count
  end

  def create
    @favourite = @current_user.favourites.new(book: @book)

    if @favourite.save
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    else
      flash.now[:danger] = t("noti.add_to_favourites_fail")
      redirect_to books_path
    end
  end

  def destroy
    @favourite = Favourite.find_by(id: params[:id])
    @book = @favourite.book
    if @favourite.destroy
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    else
      flash.now[:danger] = t("noti.remove_from_favourites_fail")
      redirect_to books_path
    end
  end

  private

  def find_book
    @book = Book.find_by(id: params[:book_id])
    return if @book

    flash[:danger] = t("noti.book_not_found")
    redirect_to books_path
  end
end
