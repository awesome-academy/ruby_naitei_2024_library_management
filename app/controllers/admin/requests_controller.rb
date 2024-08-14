class Admin::RequestsController < Admin::ApplicationController
  before_action :set_request, only: %i(update edit)

  def index
    @requests = load_requests
    @request_pagy, @requests = paginate_requests(@requests)
    @requests = @requests.includes(:books)
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
    if @request.nil?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash",
            partial: "shared/flash",
            locals: {
              message: "Request not found"
            }
          )
        end
        format.html{redirect_to requests_path, alert: "Request not found"}
      end
    elsif @request.update request_params
      handle_approved_status
      decrement_available_quantity
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    end
  end

  private

  def set_request
    @request = Request.find(params[:id])
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
    requests
  end

  def paginate_requests requests
    if params[:search].present?
      pagy(requests.search_by_book(params[:search]), items: Settings.number_20)
    else
      pagy(requests, items: Settings.number_20)
    end
  end
end
