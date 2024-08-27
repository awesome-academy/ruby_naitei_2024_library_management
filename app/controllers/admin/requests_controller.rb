class Admin::RequestsController < Admin::ApplicationController
  authorize_resource
  before_action :set_request, only: %i(update edit)

  def index
    validate_borrow_date
    @q = load_requests.ransack(params[:q] || {})
    @requests = @q.result(distinct: true)
    @requests = @requests.includes(:books)
    @request_pagy, @requests = paginate_requests(@requests)
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

  def edit; end

  def update
    selected_books = fetch_selected_books
    return if check_out_of_stock?(selected_books)

    if @request.update(request_params)
      handle_approved_status
      @request.send_email
    end
    respond_to do |format|
      format.turbo_stream
      format.html
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

  def set_request
    @request = Request.find_by(id: params[:id])
    return if @request

    flash[:danger] = t "noti.request_not_found"
    redirect_to requests_path
  end

  def request_params
    params.require(:request).permit(Request::REQUEST_PARAMS)
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

    flash[:warning] =
      "#{out_of_stock_books.join(', ')} #{t('noti.books_out_of_stock')}"
    @is_error = true
    true
  end

  def send_notification_email
    @request.send_email
  end

  def fetch_selected_books
    @request.borrow_books.includes(:book).map(&:book)
  end
end
