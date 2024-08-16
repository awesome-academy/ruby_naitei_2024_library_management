class BooksController < ApplicationController
  load_and_authorize_resource
  before_action :load_book, only: :show
  def index
    @category = Category.find_by id: params[:category]
    @keywords = params.dig(:q, :title_or_summary_cont)
    @books = filtered_books

    handle_search

    @total_books = @books.to_a.size
    @pagy, @books = pagy @books
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @initial_rating = find_initial_rating
    @comments = find_comments
    @favourite = find_favourite
    @related_books = find_related_books
  end

  private
  def handle_search
    return if @keywords.blank?

    author_search = Author.ransack(name_cont: @keywords)
    @pagy2, @authors = pagy author_search.result
    @total_authors = @authors.to_a.size
  end

  def filtered_books
    @q.result.includes(:author).filter_by_category(@category)
      .sorted_by(params[:sort])
  end

  def find_initial_rating
    @book.ratings.find_by(user_id: @current_user&.id)&.rating || 0
  end

  def find_favourite
    @current_user&.favourites&.find_by(book_id: @book.id)
  end

  def find_comments
    @book.comments.includes(:user)
  end

  def find_related_books
    category = @book.category
    category_ids = [category.id]
    category_ids += category.subcategories.pluck(:id) if category.parent_id.nil?

    Book.filter_related_books(category_ids, @book.id)
  end

  def load_book
    @book = Book.find_by(id: params[:id])
    return if @book

    flash[:danger] = t "noti.book_not_found"
    redirect_to books_path
  end
end
