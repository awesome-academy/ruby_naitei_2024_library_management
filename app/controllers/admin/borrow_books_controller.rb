class Admin::BorrowBooksController < ApplicationController
  load_and_authorize_resource
  before_action :find_borrow_book

  def mark_as_returned
    @request = @borrow_book.request
    @book = @borrow_book.book

    process_returned_book
  end

  private

  def find_borrow_book
    @borrow_book = BorrowBook.find_by(
      book_id: params[:book_id],
      request_id: params[:request_id]
    )

    return if @borrow_book

    flash[:warning] = t "noti.book_not_found"
    redirect_to borrowed_books_admin_books_path
  end

  def process_returned_book
    if @borrow_book.update(is_borrow: false, return_date: Time.current)
      update_available_quantity(@borrow_book.book_id, 1)
      respond_to do |format|
        format.turbo_stream
        format.html
      end
      flash.now[:success] = t "noti.book_returned_success"
    else
      respond_to do |format|
        format.turbo_stream
        format.html
      end
      flash.now[:danger] = t "noti.book_returned_fail"
    end
  end

  def update_available_quantity book_id, quantity_change
    book_inventory = BookInventory.find_by(book_id:)
    if book_inventory.present?
      book_inventory.increment!(:available_quantity, quantity_change)
    else
      flash[:danger] = t "noti.book_inventory_not_found"
    end
  end
end
