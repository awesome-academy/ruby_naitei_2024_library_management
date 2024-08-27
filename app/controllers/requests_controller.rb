class RequestsController < ApplicationController
  authorize_resource
  include SessionsHelper
  before_action :set_request, only: %i(edit update)
  protect_from_forgery with: :null_session

  def new
    @request = Request.new
    @books = @current_user.books_in_carts
  end

  def edit; end

  def create
    if account_banned?
      handle_banned_account
      return
    end

    @request = build_request
    selected_books = fetch_selected_books
    return redirect_to new_request_path unless handle_errors(selected_books)

    handle_create_request selected_books
  end

  def index
    validate_borrow_date
    @q = initialize_ransack
    @requests = @q.result(distinct: true)
    @request_pagy, @requests = pagy(@requests, items: Settings.number_20)
    @requests.map do |request|
      request.as_json.merge(
        books: request.books.map do |book|
          book.as_json.merge(
            book.borrowed_for_request(request.id)
          )
        end
      )
    end
  end

  def update
    if @request.update(request_params)
      @request.send_email
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    else
      flash[:danger] = t "noti.update_fail"
      redirect_to request_path(@request)
    end
  end

  def show
    @request = Request.with_user_name.with_borrow_info.find_by(id: params[:id])

    if @request.nil?
      flash[:error] = t "noti.request_not_found"
      redirect_to requests_path and return
    end

    @books = @request.books.map do |book|
      book.as_json.merge(book.borrowed_for_request(@request.id))
    end
  end

  private

  def validate_borrow_date
    if params.dig(:q, :borrow_date_gteq).present? &&
       params.dig(:q, :borrow_date_lteq).present?
      borrow_date_form = Date.parse(params[:q][:borrow_date_gteq])
                             .strftime(Settings.created_time_format)
      borrow_date_to = Date.parse(params[:q][:borrow_date_lteq])
                           .strftime(Settings.created_time_format)

      handle_wrong_borrow_date borrow_date_form, borrow_date_to
    end
  end

  def handle_wrong_borrow_date borrow_date_form, borrow_date_to
    return unless borrow_date_form > borrow_date_to

    flash.now[:alert] = t "noti.validate_borrow_date"

    params[:q][:publication_date_gteq] = ""
    params[:q][:publication_date_lteq] = ""
  end

  def handle_create_request selected_books
    if request_params["borrow_date"].to_date >= Time.current.to_date
      process_request(selected_books, request_params["borrow_date"])
    else
      flash[:warning] = t "noti.date_invalid"
      redirect_to new_request_path
    end
  end

  def initialize_ransack
    @current_user.requests
                 .with_user_name
                 .with_borrow_info
                 .newest_first
                 .ransack(params[:q] || {})
  end

  def set_request
    @request = Request.find_by(id: params[:id])
  end

  def build_request
    @current_user.requests.build(
      status: request_params["status"],
      description: request_params["description"]
    )
  end

  def fetch_selected_books
    Book.in_user_cart(@current_user)
  end

  def handle_errors selected_books
    validate_selected_books(selected_books)
    true
  rescue StandardError => e
    flash[:warning] = e.message
    false
  end

  def validate_selected_books selected_books
    if selected_books.blank?
      raise StandardError, t("noti.empty_request_noti")
    elsif selected_books.count > Settings.number_5
      raise StandardError, t("noti.over_limit_request_noti")
    elsif exceed_borrow_limit?(selected_books)
      raise StandardError, t("noti.over_limit_request_noti")
    elsif !check_available_quantity(selected_books)
      raise StandardError,
            "#{@out_of_stock_books.join(', ')} #{t('noti.books_out_of_stock')}"
    end
  end

  def exceed_borrow_limit? selected_books
    borrowed_books_count = BorrowBook.borrowed_by_user(@current_user).count
    pending_books = Request.pending_for_user(@current_user).count
    total_books_count = borrowed_books_count + pending_books

    total_books_count + selected_books.size > Settings.number_5
  end

  def process_request selected_books, borrow_date
    ActiveRecord::Base.transaction do
      @request.save!
      selected_books.each do |book|
        BorrowBook.create!(
          user: @current_user,
          book:,
          request: @request,
          borrow_date:,
          is_borrow: false
        )
        @current_user.carts.where(book_id: book.id).destroy_all
      end
      flash[:success] = t "noti.request_success_noti"
      redirect_to requests_path
    end
  end

  def request_params
    params.require(:request).permit(:status, :description, :borrow_date)
  end

  def account_banned?
    @current_user.account.ban?
  end

  def handle_banned_account
    flash[:danger] = t("noti.banned_message")
    redirect_to new_request_path
  end

  def check_available_quantity selected_books
    @out_of_stock_books = Book.available?(selected_books)
    @out_of_stock_books.empty?
  end
end
