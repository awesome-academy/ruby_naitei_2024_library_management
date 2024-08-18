class Admin::RequestsController < Admin::ApplicationController
  before_action :set_request, only: %i(update edit)

  def index
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
    return if check_out_of_stock(selected_books)

    if @request.update(request_params)
      handle_approved_status
      decrement_available_quantity
      send_notification_email if %w(approved rejected).include?(params[:status])
    end
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  private

  def set_request
    @request = Request.find_by(id: params[:id])
    return if @request

    flash[:danger] = t "noti.request_not_found"
    redirect_to requests_path
  end

  def request_params
    params.require(:request).permit(:status, :description)
  end

  def handle_approved_status
    @request.borrow_books.update_all(is_borrow: true)
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
    if params[:search].present?
      pagy(requests.search_by_book(params[:search]), items: Settings.number_20)
    else
      pagy(requests, items: Settings.number_20)
    end
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
