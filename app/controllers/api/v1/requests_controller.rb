class Api::V1::RequestsController < ApplicationController
  include Pagy::Backend
  include SessionsHelper
  before_action :set_current_user
  before_action :set_request, only: %i(update show)
  protect_from_forgery unless: ->{request.format.json?}

  def create
    if account_banned?
      return render json: {success: false,
                           error: I18n.t("noti.banned_message")},
                    status: :forbidden
    end

    @request = build_request
    selected_books = fetch_selected_books

    if handle_errors(selected_books)
      if request_params["borrow_date"].to_date >= Time.current.to_date
        process_request(selected_books, request_params["borrow_date"])
      else
        render json: {success: false, error: I18n.t("noti.date_invalid")},
               status: :unprocessable_entity
      end
    else
      handle_errors_and_render(selected_books)
    end
  end

  def index
    @q = initialize_ransack
    @requests = filter_by_status(@q.result(distinct: true))
    @request_pagy, @requests = search_requests(@requests)

    result = @requests.map do |request|
      request.as_json.merge(
        books: request.books.map do |book|
          book.as_json.merge(book.borrowed_for_request(request.id))
        end
      )
    end

    render json: {requests: result,
                  pagination: pagination_metadata(@request_pagy)},
           status: :ok
  end

  def update
    if @request.update(request_params)
      render json: {success: true, message: I18n.t("noti.update_success")}
    else
      render json: {success: false, errors: @request.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  def show
    if @request.nil?
      return render json: {success: false,
                           error: I18n.t("noti.request_not_found")},
                    status: :not_found
    end
    @books = @request.books.map do |book|
      book.as_json.merge(book.borrowed_for_request(@request.id))
    end

    render json: {
      request: @request.as_json.merge(books: @books)
    }, status: :ok
  end

  private

  def initialize_ransack
    @current_user_request.requests
                         .with_user_name
                         .with_borrow_info
                         .newest_first
                         .ransack(params[:q] || {})
  end

  def set_request
    @request = Request.find_by(id: params[:id])
  end

  def build_request
    @current_user_request.requests.build(
      status: request_params["status"],
      description: request_params["description"]
    )
  end

  def fetch_selected_books
    Book.in_user_cart(@current_user_request)
  end

  def handle_errors selected_books
    validate_selected_books(selected_books)
    true
  rescue StandardError
    false
  rescue ActiveRecord::RecordInvalid
    false
  end

  def validate_selected_books selected_books
    raise StandardError, t("noti.empty_request_noti") if selected_books.blank?

    if selected_books.count > Settings.number_5
      raise StandardError,
            t("noti.over_limit_request_noti")
    end
    return unless exceed_borrow_limit?(selected_books)

    raise StandardError,
          t("noti.over_limit_request_noti")
  end

  def exceed_borrow_limit? selected_books
    borrowed_books_count = BorrowBook.borrowed_by_user(@current_user_request)
                                     .count
    pending_books = Request.pending_for_user(@current_user_request).count
    total_books_count = borrowed_books_count + pending_books

    total_books_count + selected_books.size > Settings.number_5
  end

  def process_request selected_books, borrow_date
    ActiveRecord::Base.transaction do
      @request.save!
      selected_books.each do |book|
        BorrowBook.create!(
          user: @current_user_request,
          book:,
          request: @request,
          borrow_date:,
          is_borrow: false
        )
        @current_user_request.carts.where(book_id: book.id).destroy_all
      end
      render json: {success: true,
                    message: I18n.t("noti.request_success_noti")},
             status: :created
    end
  end

  def request_params
    params.require(:request).permit(Request::REQUEST_PARAMS)
  end

  def account_banned?
    @current_user_request.account.ban?
  end

  def handle_errors_and_render selected_books
    out_of_stock_books = Book.available?(selected_books)

    return if out_of_stock_books.empty?

    render json: {success: false,
                  error:
    "#{out_of_stock_books.join(', ')} #{I18n.t('noti.books_out_of_stock')}"},
           status: :unprocessable_entity
  end

  def filter_by_status requests
    if params[:status].blank?
      requests
    else
      requests.filter_by_status(params[:status])
    end
  end

  def search_requests requests
    if params[:search].present?
      pagy(requests.search_by_book(params[:search]), items: Settings.number_20)
    else
      pagy(requests, items: Settings.number_20)
    end
  end

  def pagination_metadata pagy
    {
      count: pagy.count,
      page: pagy.page,
      items: pagy.vars[:items],
      pages: pagy.pages
    }
  end

  def set_current_user
    user_id = params[:user_id]
    @current_user_request = User.find_by(id: user_id)
    return if @current_user_request

    render json: {error: I18n.t("noti.unauthorized")}, status: :not_found
  end
end
