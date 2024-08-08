class Admin::BorrowBooksController < ApplicationController
  def mark_as_returned
    @borrow_book = find_borrow_book

    if @borrow_book.present?
      process_returned_book
    else
      flash[:danger] = t "noti.book_not_found"
      redirect_to borrowed_books_admin_books_path
    end
  end

  private

  def find_borrow_book
    borrow_book = BorrowBook.find_by(
      book_id: params[:book_id],
      request_id: params[:request_id]
    )

    if borrow_book.nil?
      flash[:warning] = t "noti.book_not_found"
      redirect_to borrowed_books_admin_books_path
    else
      borrow_book
    end
  end

  def process_returned_book
    if @borrow_book.update(is_borrow: false, return_date: Time.current)
      update_available_quantity(@borrow_book.book_id, 1)
      flash[:success] = t "noti.book_returned_success"
    else
      flash[:danger] = t "noti.book_returned_fail"
    end
    redirect_to borrowed_books_admin_books_path
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
