class BorrowBooksController < ApplicationController
  def index
    @borrowed_books = fetch_filtered_books(params[:status], params[:search])
  end

  private

  def fetch_filtered_books status, search
    BorrowBook.with_details
              .filter_by_search(search)
              .filter_by_status(status)
              .order(borrow_date: :desc)
  end
end
