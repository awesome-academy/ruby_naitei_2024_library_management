class Admin::BooksController < Admin::ApplicationController
  authorize_resource
  before_action :load_book, only: %i(destroy edit update)
  def index
    @q = Book.ransack params[:q], auth_object: current_account

    validate_publication_date
    validate_rating

    @pagy, @books = pagy @q.result(distinct: true)
                           .includes(Book::BOOK_RELATIONS)
    @categories = Category.pluck(:name, :id)
  end

  def destroy
    if @book.destroy
      flash[:success] = t "noti.book_delete_success"
    else
      flash[:danger] = t "noti.book_delete_fail"
    end
    redirect_to admin_books_path
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new book_params

    if @book.save
      flash[:success] = t "noti.book_created_success"
      redirect_to admin_books_path
    else
      flash[:warning] = @book.errors.full_messages[0]
      redirect_to new_admin_book_path
    end
  end

  def edit; end

  def update
    if @book.update(book_params)
      flash[:success] = t "noti.book_updated_success"
      redirect_to admin_books_path
    else
      flash[:warning] = t "noti.book_updated_fail"
      redirect_to edit_admin_book_path
    end
  end

  def borrowed_books
    @borrowed_pagy, @borrowed_books = pagy(
      BorrowBook
        .admin_borrowed
        .with_details,
      items: Settings.books_per_page
    )
  end

  private

  def validate_publication_date
    if params.dig(:q, :publication_date_gteq).present? &&
       params.dig(:q, :publication_date_lteq).present?
      from_year = params[:q][:publication_date_gteq].to_i
      to_year = params[:q][:publication_date_lteq].to_i

      handle_wrong_publication_date from_year, to_year
    end
  end

  def handle_wrong_publication_date from_year, to_year
    return unless from_year > to_year

    params[:q][:publication_date_gteq] = ""
    params[:q][:publication_date_lteq] = ""

    flash[:alert] = t "noti.validate_year"
    redirect_to request.referer || admin_books_path
  end

  def validate_rating
    return if params.dig(:q, :ratings_eq).blank?

    rating_range = params[:q][:ratings_eq].split("-").map(&:to_f)

    @q = Book.ransack(params[:q].except(:ratings_eq).merge(
                        ratings_gteq: rating_range.first,
                        ratings_lteq: rating_range.last
                      ),
                      auth_object: current_account)
  end

  def load_book
    @book = Book.find_by(id: params[:id])
    return if @book

    flash[:danger] = t "noti.book_not_found"
    redirect_to admin_books_path
  end

  def book_params
    params.require(:book).permit Book::BOOK_PARAMS
  end
end
