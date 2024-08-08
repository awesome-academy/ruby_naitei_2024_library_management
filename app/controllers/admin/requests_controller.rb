class Admin::RequestsController < Admin::ApplicationController
  def index
    @requests = Request.includes(:borrow_books).newest_first

    if params[:status].present?
      @requests = @requests.filter_by_status(params[:status])
    end

    if params[:search].present?
      @request_pagy, @requests = pagy(
        @requests.search_by_book(params[:search]), items: Settings.number_5
      )
    else
      @request_pagy, @requests = pagy(@requests, items: Settings.number_5)
    end
  end
end
