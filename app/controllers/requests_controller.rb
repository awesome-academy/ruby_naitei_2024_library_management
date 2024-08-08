class RequestsController < ApplicationController
  include SessionsHelper
  before_action :authenticate_account
  before_action :authenticate_user, only: %i(index)
  protect_from_forgery with: :null_session

  def new
    @request = Request.new
    @books = current_user.books_in_carts
  end

  def create
    if account_banned?
      handle_banned_account
      return
    end

    @request = build_request
    selected_books = fetch_selected_books

    if handle_errors(selected_books)
      process_request(selected_books, request_params["borrow_date"])
    else
      redirect_to new_request_path
    end
  end

  def index
    @requests = current_user.requests.includes(:borrow_books).newest_first
    @requests = filter_by_status(@requests)
    @request_pagy, @requests = search_requests(@requests)
  end

  def borrowed _books
    @borrowed_pagy, @borrowed_books = pagy(
      BorrowBook.borrowed.with_details,
      items: Settings.number_5
    )
  end

  def update
    @request = Request.find_by(id: params[:id])

    if @request.nil?
      render_not_found
    elsif @request.update(request_params)
      if params[:status] == "approved"
        handle_approved_status
        decrement_available_quantity
      end
      @request.send_email if %w(approved rejected).include?(params[:status])
    else
      render_update_error
    end
  end

  private

  def build_request
    current_user.requests.build(
      status: request_params["status"],
      description: request_params["description"]
    )
  end

  def fetch_requests_with_books requests
    requests.includes(:books)
  end

  def fetch_selected_books
    Book.in_user_cart(current_user)
  end

  def handle_errors selected_books
    validate_selected_books(selected_books)
    true
  rescue StandardError => e
    flash[:warning] = e.message
    false
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = t("noti.request_failure_noti")
    render :new
    false
  end

  def validate_selected_books selected_books
    if selected_books.blank?
      raise StandardError, t("noti.empty_request_noti")
    elsif selected_books.count > Settings.number_5
      raise StandardError, t("noti.over_limit_request_noti")
    elsif exceed_borrow_limit?(selected_books)
      raise StandardError, t("noti.over_limit_request_noti")
    end
  end

  def exceed_borrow_limit? selected_books
    borrowed_books_count = BorrowBook.borrowed_by_user(current_user).count
    pending_books = Request.pending_for_user(current_user).count
    total_books_count = borrowed_books_count + pending_books

    total_books_count + selected_books.size > Settings.number_5
  end

  def process_request selected_books, borrow_date
    ActiveRecord::Base.transaction do
      @request.save!
      selected_books.each do |book|
        BorrowBook.create!(
          user: current_user,
          book:,
          request: @request,
          borrow_date:,
          is_borrow: false
        )
        current_user.carts.where(book_id: book.id).destroy_all
      end
      flash[:success] = t "noti.request_success_noti"
      redirect_to requests_path
    end
  end

  def request_params
    params.require(:request).permit(:status, :description, :borrow_date)
  end

  def handle_approved_status
    @request.borrow_books.update_all(is_borrow: true)
  end

  def render_not_found
    render json: {success: false, error: t("noti.request_not_found")},
           status: :not_found
  end

  def render_update_error
    render json: {success: false, errors: @request.errors.full_messages}
  end

  def account_banned?
    current_user.account.ban?
  end

  def handle_banned_account
    flash[:danger] = t("noti.banned_message")
    redirect_to new_request_path
  end

  def decrement_available_quantity
    @request.borrow_books.each do |borrow_book|
      book_inventory = BookInventory.find_by(book_id: borrow_book.book_id)
      if book_inventory.present?
        book_inventory.decrement!(:available_quantity, 1)
      else
        flash[:danger] = t "noti.book_inventory_not_found"
      end
    end
  end

  def filter_by_status requests
    return requests if params[:status].blank?

    requests.filter_by_status(params[:status])
  end

  def search_requests requests
    if params[:search].present?
      pagy(requests.search_by_book(params[:search]), items: Settings.number_5)
    else
      pagy(requests, items: Settings.number_5)
    end
  end
end
