class RequestsController < ApplicationController
  include SessionsHelper
  before_action :authenticate_user
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

    @request = current_user.requests.build(request_params)
    selected_books = fetch_selected_books

    begin
      handle_errors(selected_books)
      process_request(selected_books)
    rescue StandardError => e
      flash[:warning] = e.message
      redirect_to new_request_path
    rescue ActiveRecord::RecordInvalid
      flash[:danger] = t("noti.request_failure_noti")
      render :new
    end
  end

  def index
    @requests = current_user.requests.includes(:borrow_books)

    if params[:status].present?
      @requests = @requests.filter_by_status(params[:status])
    end

    return if params[:search].blank?

    @requests = @requests.search_by_book(params[:search])
  end

  def borrowed_books
    @pagy, @borrowed_books = pagy(
      BorrowBook
        .borrowed
        .with_details
    )
  end

  def update
    @request = Request.find_by(id: params[:id])

    if @request.nil?
      render_not_found
    elsif @request.update(request_params)
      handle_approved_status if params[:status] == "approved"
      @request.send_email if %w(approved rejected).include?(params[:status])
      render json: {success: true}
    else
      render_update_error
    end
  end

  private

  def fetch_requests_with_books requests
    requests.includes(:books)
  end

  def fetch_selected_books
    Book.in_user_cart(current_user)
  end

  def handle_errors selected_books
    if selected_books.blank?
      raise StandardError, t("noti.empty_request_noti")
    elsif selected_books.count > Settings.max_books
      raise StandardError, t("noti.over_limit_request_noti")
    elsif exceed_borrow_limit?(selected_books)
      raise StandardError, t("noti.over_limit_request_noti")
    end
  end

  def exceed_borrow_limit? selected_books
    borrowed_books_count = BorrowBook.borrowed_by_user(current_user).count
    pending_books = Request.pending_for_user(current_user).count
    total_books_count = borrowed_books_count + pending_books

    total_books_count + selected_books.size > Settings.max_books
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
          is_borrow: false
        )
        current_user.carts.where(book_id: book.id).destroy_all
      end
      flash[:success] = t "noti.request_success_noti"
      redirect_to requests_path
    end
  end

  def request_params
    params.require(:request).permit(:status, :description)
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
end
