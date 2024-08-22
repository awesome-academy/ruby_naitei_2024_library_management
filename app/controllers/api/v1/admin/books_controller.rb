class Api::V1::Admin::BooksController < ApplicationController
  include Pagy::Backend
  before_action :load_book, only: %i(destroy edit update)
  protect_from_forgery unless: ->{request.format.json?}

  def index
    @q = Book.ransack params[:q], auth_object: api_admin_user
    @pagy, @books = pagy @q.result(distinct: true)
                           .includes(Book::BOOK_RELATIONS)

    render json: {
      books: @books.as_json(include: [:category, :author, :book_series,
:ratings]),
      categories: Category.pluck(:name, :id),
      total_books: @books.count,
      pagy: pagination_metadata(@pagy)
    }, status: :ok
  end

  def destroy
    if @book.destroy
      render json: {message: I18n.t("noti.book_delete_success")}, status: :ok
    else
      render json: {error: I18n.t("noti.book_delete_fail")},
             status: :unprocessable_entity
    end
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      render json: {
        message: I18n.t("noti.book_created_success"),
        book: @book.as_json
      }, status: :created
    else
      render json: {errors: @book.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @book.update(book_params)
      render json: {
        message: I18n.t("noti.book_updated_success"),
        book: @book.as_json
      }, status: :ok
    else
      render json: {errors: @book.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def borrowed_books
    @borrowed_pagy, @borrowed_books = pagy BorrowBook.admin_borrowed
                                                     .with_details

    render json: {
      borrowed_books: @borrowed_books.as_json,
      total_borrowed: @borrowed_books.count,
      pagy: pagination_metadata(@pagy)
    }, status: :ok
  end

  private

  def api_admin_user
    OpenStruct.new is_admin: true
  end

  def load_book
    @book = Book.find_by id: params[:id]
    return if @book

    render json: {error: I18n.t("noti.book_not_found")}, status: :not_found
  end

  def book_params
    params.require(:book).permit(Book::BOOK_PARAMS)
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
