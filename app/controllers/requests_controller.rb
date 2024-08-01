class RequestsController < ApplicationController
  protect_from_forgery with: :null_session

  def new
    @request = Request.new
    @books = current_user.books_in_carts
  end

  def create
    @request = current_user.requests.build(request_params)
    selected_books = fetch_selected_books

    if handle_empty_books(selected_books) ||
       handle_book_limit(selected_books) ||
       handle_borrowed_books_limit(selected_books)
      return
    end

    process_request selected_books
  rescue ActiveRecord::RecordInvalid
    flash[:notice] = t "noti.request_failure_noti"
    render :new
  end

  private

  def fetch_selected_books
    Book.in_user_cart(current_user)
  end

  def handle_empty_books selected_books
    return if selected_books.present?

    flash[:notice] = t "noti.empty_request_noti"
    redirect_to new_request_path
    true
  end

  def handle_book_limit selected_books
    return unless selected_books.count > Settings.max_books

    flash[:notice] = t "noti.over_limit_request_noti"
    redirect_to new_request_path
    true
  end

  def handle_borrowed_books_limit selected_books
    borrowed_books_count = BorrowBook.count_for_user(current_user.id)
    total_books_count = borrowed_books_count + selected_books.size

    return false if total_books_count <= Settings.max_books

    flash[:alert] = t "noti.over_limit_request_noti"
    redirect_to root_path
    true
  end

  def process_request selected_books
    ActiveRecord::Base.transaction do
      @request.save!
      selected_books.each do |book|
        BorrowBook.create!(
          user: current_user,
          book:,
          request: @request,
          borrow_date: Time.current,
          is_borrow: true
        )
        current_user.carts.where(book_id: book.id).destroy_all
      end
      flash[:notice] = t "noti.request_success_noti"
      redirect_to root_path
    end
  end

  def request_params
    params.require(:request).permit(:status)
  end
end