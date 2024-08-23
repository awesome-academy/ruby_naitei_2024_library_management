class Api::V1::BooksController < ApplicationController
  include Pagy::Backend
  before_action :load_search, only: :index
  before_action :load_book, only: :show
  protect_from_forgery unless: ->{request.format.json?}

  def index
    @category = Category.find_by id: params[:category]
    @keywords = params.dig(:q, :title_or_summary_cont)
    @books = filtered_books
    @total_books = @books.to_a.size
    handle_search

    @pagy, @books = pagy(@books)

    render json: {
      books: @books.as_json(include: :author),
      total_books: @total_books,
      pagy: pagination_metadata(@pagy)
    }, status: :ok
  end

  def show
    @initial_rating = find_initial_rating
    @comments = find_comments
    @favourite = find_favourite
    @related_books = find_related_books

    render json: {
      book: @book.as_json(include: :author),
      rating: @initial_rating,
      comments: @comments.as_json(include: :user),
      favourite: @favourite.present?,
      related_books: @related_books.as_json(include: :author)
    }, status: :ok
  end

  private

  def load_search
    @q = Book.ransack(params[:q])
  end

  def handle_search
    return if @keywords.blank?

    author_search = Author.ransack(name_cont: @keywords)
    @pagy2, @authors = pagy author_search.result
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

    render json: {error: I18n.t("noti.book_not_found")}, status: :not_found
  end

  def pagination_metadata pagy
    {
      count: pagy.count,
      page: pagy.page,
      items: pagy.vars[:items],
      pages: pagy.pages
    }
  end
end
