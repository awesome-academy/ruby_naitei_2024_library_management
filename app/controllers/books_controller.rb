class BooksController < ApplicationController
  def index
    @category = Category.find_by(id: params[:category])
    @total_books = filtered_books.count
    @keywords = params[:search]
    @pagy, @books = pagy(filtered_books)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show; end

  private
  def filtered_books
    Book.filter_by_category(@category)
        .filter_by_search(params[:search])
        .sorted_by(params[:sort])
  end
end
