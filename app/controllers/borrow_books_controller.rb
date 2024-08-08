class BorrowBooksController < ApplicationController
  def index
    @borrowed_pagy, @borrowed_books = pagy(
      fetch_filtered_books(params[:status],
                           params[:search]), items: Settings.number_5
    )
  end

  private

  def fetch_filtered_books status, search
    current_user.borrow_books.with_details
                .filter_by_search(search)
                .filter_by_status(status)
                .order(borrow_date: :desc)
  end
end
