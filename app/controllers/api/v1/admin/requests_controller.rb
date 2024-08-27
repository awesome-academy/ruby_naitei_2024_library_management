class Api::V1::Admin::RequestsController < ApplicationController
  include Pagy::Backend
  before_action :set_request, only: %i(update edit)
  protect_from_forgery unless: ->{request.format.json?}

  def index
    @q = load_requests.ransack(params[:q] || {})
    @requests = @q.result(distinct: true)
    @requests = @requests.includes(:books)
    @request_pagy, @requests = paginate_requests(@requests)
    result = @requests.map do |request|
      request.as_json.merge(
        books: request.books.map do |book|
          book.as_json.merge(
            book.borrowed_for_request(request.id)
          )
        end
      )
    end

    render json: {
      requests: result,
      pagination: pagination_metadata(@request_pagy)
    }, status: :ok
  end

  def edit; end

  def update
    selected_books = fetch_selected_books
    if check_out_of_stock?(selected_books)
      return render json: {error: I18n.t("noti.books_out_of_stock")},
                    status: :unprocessable_entity
    end

    if @request.update(request_params)
      handle_approved_status
      send_notification_email
      render json: {message: I18n.t("noti.update_success_noti")}, status: :ok
    else
      render json: {errors: @request.errors.full_messages},
             status: :unprocessable_entity
    end
  end

  private

  def set_request
    @request = Request.find_by(id: params[:id])
    return if @request

    render json: {error: I18n.t("noti.request_not_found")},
           status: :not_found
  end

  def request_params
    params.require(:request).permit(:status, :description)
  end

  def handle_approved_status
    return unless @request.approved?

    @request.borrow_books.update_all(is_borrow: true)
    UpdateAvailableQuantityJob.perform_later(
      @request.borrow_books.pluck(:book_id), -1
    )
  end

  def load_requests
    requests = Request.with_user_name.with_borrow_info.newest_first

    if params[:status].present?
      requests = requests.filter_by_status(params[:status])
    end
    if params[:q].blank? || !params[:q][:s]
      requests = requests.order(created_at: :desc)
    end
    requests
  end

  def paginate_requests requests
    pagy(requests, items: Settings.number_20)
  end

  def check_out_of_stock? selected_books
    out_of_stock_books = Book.available?(selected_books)
    return false if out_of_stock_books.blank?

    render json: {warning:
      "#{out_of_stock_books.join(', ')} #{I18n.t('noti.books_out_of_stock')}"},
           status: :unprocessable_entity
    true
  end

  def send_notification_email
    @request.send_email
  end

  def fetch_selected_books
    @request.borrow_books.includes(:book).map(&:book)
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
